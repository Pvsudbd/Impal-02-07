import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../models/kelompok/group_repository.dart';

class GroupController {
  static const _jsonHeaders = {'Content-Type': 'application/json'};
  static const _validPriorities = {'HIGH', 'MEDIUM', 'LOW'};

  static String? _getUserId(Request req) {
    final user =
        (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ?? user?['idStudent']) as String?;
  }

  static Response _unauthorized() {
    return Response(
      401,
      body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
      headers: _jsonHeaders,
    );
  }

  static Response _badRequest(String message) {
    return Response.badRequest(
      body: jsonEncode({'status': 'error', 'message': message}),
      headers: _jsonHeaders,
    );
  }

  static Response _mapError(Object e, StackTrace stack, String contextLabel) {
    if (e is FormatException) {
      return _badRequest('Format JSON tidak valid.');
    }
    if (e is GroupBadRequestException) {
      return _badRequest(e.message);
    }
    if (e is GroupForbiddenException) {
      return Response(
        403,
        body: jsonEncode({'status': 'error', 'message': e.message}),
        headers: _jsonHeaders,
      );
    }
    if (e is GroupNotFoundException) {
      return Response(
        404,
        body: jsonEncode({'status': 'error', 'message': e.message}),
        headers: _jsonHeaders,
      );
    }
    if (e is GroupConflictException) {
      return Response(
        409,
        body: jsonEncode({'status': 'error', 'message': e.message}),
        headers: _jsonHeaders,
      );
    }
    print('[GROUP] $contextLabel error: $e\n$stack');
    return Response.internalServerError(
      body: jsonEncode({
        'status': 'error',
        'message': 'Terjadi kesalahan saat memproses permintaan kelompok.',
      }),
      headers: _jsonHeaders,
    );
  }

  static Future<Map<String, dynamic>> _readJsonObject(
    Request req, {
    bool allowEmpty = false,
  }) async {
    final bodyText = await req.readAsString();
    if (bodyText.trim().isEmpty) {
      if (allowEmpty) return <String, dynamic>{};
      throw GroupBadRequestException('Request body tidak boleh kosong.');
    }
    final decoded = jsonDecode(bodyText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Not a JSON object');
    }
    return decoded;
  }

  static List<String>? _validateTags(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List || raw.length > 20) return null;
    final tags = <String>[];
    for (final item in raw) {
      if (item is! String) return null;
      final trimmed = item.trim();
      if (trimmed.isNotEmpty) {
        if (trimmed.length > 32) return null;
        tags.add(trimmed);
      }
    }
    return tags;
  }

  // ─── GROUPS & MEMBERS ─────────────────────────────────────────────────────

  // GET /api/groups?q=
  static Future<Response> listGroups(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final query = req.url.queryParameters['q'];
      final groups = await GroupRepository.listForUser(idUser, query: query);
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': groups.length,
          'data': groups,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'listGroups');
    }
  }

  // POST /api/groups
  static Future<Response> createGroup(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      final groupName =
          (body['groupName'] ?? body['group_name'] ?? body['name'])
              ?.toString()
              .trim();
      if (groupName == null || groupName.isEmpty) {
        return _badRequest('Field groupName wajib diisi.');
      }
      if (groupName.length > 100) {
        return _badRequest('Panjang groupName maksimal 100 karakter.');
      }

      final created = await GroupRepository.createGroup(
        idLeader: idUser,
        groupName: groupName,
        description: (body['description'] ?? '').toString(),
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Kelompok berhasil dibuat.',
          'data': created,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'createGroup');
    }
  }

  // GET /api/groups/<idGroup>
  static Future<Response> getGroupDetail(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final detail = await GroupRepository.getDetail(idGroup, idUser);
      return Response.ok(
        jsonEncode({'status': 'success', 'data': detail}),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'getGroupDetail');
    }
  }

  // PUT /api/groups/<idGroup>
  static Future<Response> updateGroup(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      String? groupName;
      if (body.containsKey('groupName') ||
          body.containsKey('group_name') ||
          body.containsKey('name')) {
        groupName = (body['groupName'] ?? body['group_name'] ?? body['name'])
            ?.toString()
            .trim();
        if (groupName == null || groupName.isEmpty) {
          return _badRequest('Field groupName tidak boleh kosong.');
        }
        if (groupName.length > 100) {
          return _badRequest('Panjang groupName maksimal 100 karakter.');
        }
      }

      final updated = await GroupRepository.updateGroup(
        idGroup: idGroup,
        idUser: idUser,
        groupName: groupName,
        description: body.containsKey('description')
            ? (body['description'] ?? '').toString()
            : null,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Data kelompok berhasil diperbarui.',
          'data': updated,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'updateGroup');
    }
  }

  // POST /api/groups/join
  static Future<Response> joinGroup(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      final inviteCode =
          (body['inviteCode'] ?? body['invite_code'] ?? body['code'])
              ?.toString()
              .trim();
      if (inviteCode == null || inviteCode.isEmpty) {
        return _badRequest('Field inviteCode wajib diisi.');
      }

      final joined = await GroupRepository.joinByInviteCode(
        idUser: idUser,
        inviteCode: inviteCode,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Berhasil bergabung ke kelompok.',
          'data': joined,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'joinGroup');
    }
  }

  // DELETE /api/groups/<idGroup>/leave
  static Future<Response> leaveGroup(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      await GroupRepository.leaveGroup(idGroup: idGroup, idUser: idUser);
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Berhasil keluar dari kelompok.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'leaveGroup');
    }
  }

  // DELETE /api/groups/<idGroup>
  static Future<Response> disbandGroup(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      await GroupRepository.disbandGroup(idGroup: idGroup, idUser: idUser);
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Kelompok berhasil dibubarkan.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'disbandGroup');
    }
  }

  // ─── MILESTONES ───────────────────────────────────────────────────────────

  static Future<Response> listMilestones(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final data = await GroupRepository.listMilestones(idGroup, idUser);
      return Response.ok(
        jsonEncode({'status': 'success', 'count': data.length, 'data': data}),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'listMilestones');
    }
  }

  static Future<Response> createMilestone(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      final title = body['title']?.toString().trim();
      final rawDeadline = body['deadline']?.toString().trim();
      final deadline =
          rawDeadline != null ? DateTime.tryParse(rawDeadline) : null;

      if (title == null || title.isEmpty || deadline == null) {
        return _badRequest(
          'Field wajib diisi: title dan deadline (format ISO8601).',
        );
      }
      if (title.length > 150) {
        return _badRequest('Panjang title maksimal 150 karakter.');
      }

      final created = await GroupRepository.createMilestone(
        idGroup: idGroup,
        idUser: idUser,
        title: title,
        description: (body['description'] ?? '').toString(),
        deadline: deadline,
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Milestone berhasil dibuat.',
          'data': created,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'createMilestone');
    }
  }

  static Future<Response> updateMilestone(
    Request req,
    String idGroup,
    String idMilestone,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      String? title;
      if (body.containsKey('title')) {
        title = body['title']?.toString().trim();
        if (title == null || title.isEmpty) {
          return _badRequest('Field title tidak boleh kosong.');
        }
        if (title.length > 150) {
          return _badRequest('Panjang title maksimal 150 karakter.');
        }
      }

      DateTime? deadline;
      if (body.containsKey('deadline') && body['deadline'] != null) {
        deadline = DateTime.tryParse(body['deadline'].toString().trim());
        if (deadline == null) {
          return _badRequest('Format tanggal deadline tidak valid.');
        }
      }

      final updated = await GroupRepository.updateMilestone(
        idGroup: idGroup,
        idMilestone: idMilestone,
        idUser: idUser,
        title: title,
        description: body.containsKey('description')
            ? (body['description'] ?? '').toString()
            : null,
        deadline: deadline,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Milestone berhasil diperbarui.',
          'data': updated,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'updateMilestone');
    }
  }

  static Future<Response> deleteMilestone(
    Request req,
    String idGroup,
    String idMilestone,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      await GroupRepository.deleteMilestone(
        idGroup: idGroup,
        idMilestone: idMilestone,
        idUser: idUser,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Milestone berhasil dihapus.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'deleteMilestone');
    }
  }

  // ─── GROUP TASKS ──────────────────────────────────────────────────────────

  static Future<Response> listGroupTasks(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final qp = req.url.queryParameters;
      final assignedToMe =
          qp['assignedToMe']?.trim().toLowerCase() == 'true' ||
              qp['assignedToMe'] == '1';
      final idMilestone = qp['idMilestone'];
      bool? isCompleted;
      if (qp.containsKey('isCompleted') && qp['isCompleted']!.isNotEmpty) {
        final raw = qp['isCompleted']!.trim().toLowerCase();
        isCompleted = raw == 'true' || raw == '1';
      }

      final data = await GroupRepository.listGroupTasks(
        idGroup,
        idUser,
        assignedToMe: assignedToMe,
        idMilestone: idMilestone,
        isCompleted: isCompleted,
      );

      return Response.ok(
        jsonEncode({'status': 'success', 'count': data.length, 'data': data}),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'listGroupTasks');
    }
  }

  static Future<Response> createGroupTask(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      final title =
          (body['title'] ?? body['taskTitle'] ?? body['task_title'])
              ?.toString()
              .trim();
      final rawDeadline = body['deadline']?.toString().trim();
      final deadline =
          rawDeadline != null ? DateTime.tryParse(rawDeadline) : null;

      if (title == null || title.isEmpty || deadline == null) {
        return _badRequest(
          'Field wajib diisi: title dan deadline (format ISO8601).',
        );
      }
      if (title.length > 150) {
        return _badRequest('Panjang title maksimal 150 karakter.');
      }

      var gradeWeight = 20.0;
      final rawWeight = body['gradeWeight'] ?? body['grade_weight'];
      if (rawWeight != null) {
        final parsed = rawWeight is num
            ? rawWeight.toDouble()
            : double.tryParse(rawWeight.toString());
        if (parsed == null || parsed < 0 || parsed > 100) {
          return _badRequest(
            'Field gradeWeight harus bernilai antara 0 sampai 100.',
          );
        }
        gradeWeight = parsed;
      }

      final rawAuto = body['isFuzzyAuto'] ?? body['is_fuzzy_auto'];
      final isFuzzyAuto = rawAuto == null
          ? true
          : (rawAuto == true || rawAuto == 1 || rawAuto == 'true');

      final rawPriority = body['priority']?.toString().trim().toUpperCase();
      if (!isFuzzyAuto &&
          rawPriority != null &&
          rawPriority.isNotEmpty &&
          !_validPriorities.contains(rawPriority)) {
        return _badRequest('Field priority harus HIGH, MEDIUM, atau LOW.');
      }

      var tags = const <String>[];
      if (body.containsKey('tags') && body['tags'] != null) {
        final parsedTags = _validateTags(body['tags']);
        if (parsedTags == null) {
          return _badRequest(
            'Field tags harus berupa list string (maksimal 20 tag).',
          );
        }
        tags = parsedTags;
      }

      final created = await GroupRepository.createGroupTask(
        idGroup: idGroup,
        idUser: idUser,
        taskTitle: title,
        description: (body['description'] ?? '').toString(),
        deadline: deadline,
        gradeWeight: gradeWeight,
        isFuzzyAuto: isFuzzyAuto,
        manualPriority: rawPriority,
        idAssignedTo: (body['idAssignedTo'] ?? body['id_assigned_to'])
            ?.toString(),
        idMilestone:
            (body['idMilestone'] ?? body['id_milestone'])?.toString(),
        tags: tags,
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Tugas kelompok berhasil dibuat.',
          'data': created,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'createGroupTask');
    }
  }

  static Future<Response> updateGroupTask(
    Request req,
    String idGroup,
    String idGroupTask,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      String? title;
      if (body.containsKey('title') ||
          body.containsKey('taskTitle') ||
          body.containsKey('task_title')) {
        title = (body['title'] ?? body['taskTitle'] ?? body['task_title'])
            ?.toString()
            .trim();
        if (title == null || title.isEmpty) {
          return _badRequest('Field title tidak boleh kosong.');
        }
        if (title.length > 150) {
          return _badRequest('Panjang title maksimal 150 karakter.');
        }
      }

      DateTime? deadline;
      if (body.containsKey('deadline') && body['deadline'] != null) {
        deadline = DateTime.tryParse(body['deadline'].toString().trim());
        if (deadline == null) {
          return _badRequest('Format tanggal deadline tidak valid.');
        }
      }

      double? gradeWeight;
      if (body.containsKey('gradeWeight') || body.containsKey('grade_weight')) {
        final rawWeight = body['gradeWeight'] ?? body['grade_weight'];
        final parsed = rawWeight is num
            ? rawWeight.toDouble()
            : double.tryParse(rawWeight?.toString() ?? '');
        if (parsed == null || parsed < 0 || parsed > 100) {
          return _badRequest(
            'Field gradeWeight harus bernilai antara 0 sampai 100.',
          );
        }
        gradeWeight = parsed;
      }

      bool? isFuzzyAuto;
      if (body.containsKey('isFuzzyAuto') || body.containsKey('is_fuzzy_auto')) {
        final rawAuto = body['isFuzzyAuto'] ?? body['is_fuzzy_auto'];
        isFuzzyAuto = rawAuto == true || rawAuto == 1 || rawAuto == 'true';
      }

      bool? isCompleted;
      if (body.containsKey('isCompleted') || body.containsKey('is_completed')) {
        final rawComp = body['isCompleted'] ?? body['is_completed'];
        isCompleted = rawComp == true || rawComp == 1 || rawComp == 'true';
      }

      final rawPriority = body['priority']?.toString().trim().toUpperCase();
      if (rawPriority != null &&
          rawPriority.isNotEmpty &&
          !_validPriorities.contains(rawPriority)) {
        return _badRequest('Field priority harus HIGH, MEDIUM, atau LOW.');
      }

      List<String>? tags;
      if (body.containsKey('tags')) {
        tags = _validateTags(body['tags']);
        if (tags == null) {
          return _badRequest(
            'Field tags harus berupa list string (maksimal 20 tag).',
          );
        }
      }

      final updated = await GroupRepository.updateGroupTask(
        idGroup: idGroup,
        idGroupTask: idGroupTask,
        idUser: idUser,
        taskTitle: title,
        description: body.containsKey('description')
            ? (body['description'] ?? '').toString()
            : null,
        deadline: deadline,
        gradeWeight: gradeWeight,
        isFuzzyAuto: isFuzzyAuto,
        manualPriority: rawPriority,
        idAssignedTo: (body['idAssignedTo'] ?? body['id_assigned_to'])
            ?.toString(),
        clearAssignee: body['clearAssignee'] == true,
        idMilestone:
            (body['idMilestone'] ?? body['id_milestone'])?.toString(),
        clearMilestone: body['clearMilestone'] == true,
        isCompleted: isCompleted,
        tags: tags,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Tugas kelompok berhasil diperbarui.',
          'data': updated,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'updateGroupTask');
    }
  }

  static Future<Response> toggleGroupTaskComplete(
    Request req,
    String idGroup,
    String idGroupTask,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req, allowEmpty: true);
      bool? isCompleted;
      if (body.containsKey('isCompleted') || body.containsKey('is_completed')) {
        final raw = body['isCompleted'] ?? body['is_completed'];
        isCompleted = raw == true || raw == 1 || raw == 'true';
      }

      final updated = await GroupRepository.toggleGroupTaskComplete(
        idGroup: idGroup,
        idGroupTask: idGroupTask,
        idUser: idUser,
        isCompleted: isCompleted,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Status tugas kelompok berhasil diperbarui.',
          'data': updated,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'toggleGroupTaskComplete');
    }
  }

  static Future<Response> deleteGroupTask(
    Request req,
    String idGroup,
    String idGroupTask,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      await GroupRepository.deleteGroupTask(
        idGroup: idGroup,
        idGroupTask: idGroupTask,
        idUser: idUser,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Tugas kelompok berhasil dihapus.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'deleteGroupTask');
    }
  }

  // ─── SUBTASKS ─────────────────────────────────────────────────────────────

  static Future<Response> listSubTasks(
    Request req,
    String idGroup,
    String idGroupTask,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final data = await GroupRepository.listSubTasks(
        idGroup,
        idGroupTask,
        idUser,
      );
      return Response.ok(
        jsonEncode({'status': 'success', 'count': data.length, 'data': data}),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'listSubTasks');
    }
  }

  static Future<Response> createSubTask(
    Request req,
    String idGroup,
    String idGroupTask,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      final title =
          (body['subTaskTitle'] ?? body['sub_task_title'] ?? body['title'])
              ?.toString()
              .trim();
      final rawDeadline = body['deadline']?.toString().trim();
      final deadline =
          rawDeadline != null ? DateTime.tryParse(rawDeadline) : null;

      if (title == null || title.isEmpty || deadline == null) {
        return _badRequest(
          'Field wajib diisi: subTaskTitle dan deadline (format ISO8601).',
        );
      }
      if (title.length > 150) {
        return _badRequest('Panjang subTaskTitle maksimal 150 karakter.');
      }

      var gradeWeight = 10.0;
      final rawWeight = body['gradeWeight'] ?? body['grade_weight'];
      if (rawWeight != null) {
        final parsed = rawWeight is num
            ? rawWeight.toDouble()
            : double.tryParse(rawWeight.toString());
        if (parsed == null || parsed < 0 || parsed > 100) {
          return _badRequest(
            'Field gradeWeight harus bernilai antara 0 sampai 100.',
          );
        }
        gradeWeight = parsed;
      }

      final created = await GroupRepository.createSubTask(
        idGroup: idGroup,
        idGroupTask: idGroupTask,
        idUser: idUser,
        subTaskTitle: title,
        description: (body['description'] ?? '').toString(),
        deadline: deadline,
        gradeWeight: gradeWeight,
        idAssignedTo: (body['idAssignedTo'] ?? body['id_assigned_to'])
            ?.toString(),
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Sub-tugas berhasil dibuat.',
          'data': created,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'createSubTask');
    }
  }

  static Future<Response> toggleSubTaskComplete(
    Request req,
    String idGroup,
    String idGroupTask,
    String idSubTask,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req, allowEmpty: true);
      bool? isCompleted;
      if (body.containsKey('isCompleted') || body.containsKey('is_completed')) {
        final raw = body['isCompleted'] ?? body['is_completed'];
        isCompleted = raw == true || raw == 1 || raw == 'true';
      }

      final updated = await GroupRepository.toggleSubTaskComplete(
        idGroup: idGroup,
        idGroupTask: idGroupTask,
        idSubTask: idSubTask,
        idUser: idUser,
        isCompleted: isCompleted,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Status sub-tugas berhasil diperbarui.',
          'data': updated,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'toggleSubTaskComplete');
    }
  }

  static Future<Response> deleteSubTask(
    Request req,
    String idGroup,
    String idGroupTask,
    String idSubTask,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      await GroupRepository.deleteSubTask(
        idGroup: idGroup,
        idGroupTask: idGroupTask,
        idSubTask: idSubTask,
        idUser: idUser,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Sub-tugas berhasil dihapus.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'deleteSubTask');
    }
  }

  // ─── MEETINGS ─────────────────────────────────────────────────────────────

  static Future<Response> listMeetings(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final data = await GroupRepository.listMeetings(idGroup, idUser);
      return Response.ok(
        jsonEncode({'status': 'success', 'count': data.length, 'data': data}),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'listMeetings');
    }
  }

  static Future<Response> createMeeting(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      final title =
          (body['meetingTitle'] ?? body['meeting_title'] ?? body['title'])
              ?.toString()
              .trim();
      final rawStart = (body['startTime'] ?? body['start_time'])
          ?.toString()
          .trim();
      final startTime =
          rawStart != null ? DateTime.tryParse(rawStart) : null;
      final location =
          (body['platformLocation'] ??
                  body['platform_location'] ??
                  body['location'] ??
                  'Online')
              .toString()
              .trim();

      if (title == null || title.isEmpty || startTime == null) {
        return _badRequest(
          'Field wajib diisi: meetingTitle dan startTime (format ISO8601).',
        );
      }
      if (title.length > 100 || location.length > 100) {
        return _badRequest(
          'Panjang meetingTitle dan platformLocation maksimal 100 karakter.',
        );
      }

      final created = await GroupRepository.createMeeting(
        idGroup: idGroup,
        idUser: idUser,
        meetingTitle: title,
        description: (body['description'] ?? '').toString(),
        startTime: startTime,
        platformLocation: location.isEmpty ? 'Online' : location,
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Jadwal rapat berhasil dibuat.',
          'data': created,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'createMeeting');
    }
  }

  static Future<Response> updateMeeting(
    Request req,
    String idGroup,
    String idMeeting,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final body = await _readJsonObject(req);
      String? title;
      if (body.containsKey('meetingTitle') ||
          body.containsKey('meeting_title') ||
          body.containsKey('title')) {
        title =
            (body['meetingTitle'] ?? body['meeting_title'] ?? body['title'])
                ?.toString()
                .trim();
        if (title == null || title.isEmpty) {
          return _badRequest('Field meetingTitle tidak boleh kosong.');
        }
        if (title.length > 100) {
          return _badRequest('Panjang meetingTitle maksimal 100 karakter.');
        }
      }

      DateTime? startTime;
      if (body.containsKey('startTime') || body.containsKey('start_time')) {
        final rawStart = (body['startTime'] ?? body['start_time'])?.toString();
        startTime = rawStart != null ? DateTime.tryParse(rawStart.trim()) : null;
        if (startTime == null) {
          return _badRequest('Format startTime tidak valid.');
        }
      }

      String? location;
      if (body.containsKey('platformLocation') ||
          body.containsKey('platform_location') ||
          body.containsKey('location')) {
        location = (body['platformLocation'] ??
                body['platform_location'] ??
                body['location'])
            ?.toString()
            .trim();
        if (location != null && location.length > 100) {
          return _badRequest('Panjang platformLocation maksimal 100 karakter.');
        }
      }

      final updated = await GroupRepository.updateMeeting(
        idGroup: idGroup,
        idMeeting: idMeeting,
        idUser: idUser,
        meetingTitle: title,
        description: body.containsKey('description')
            ? (body['description'] ?? '').toString()
            : null,
        startTime: startTime,
        platformLocation: location,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal rapat berhasil diperbarui.',
          'data': updated,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'updateMeeting');
    }
  }

  static Future<Response> deleteMeeting(
    Request req,
    String idGroup,
    String idMeeting,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      await GroupRepository.deleteMeeting(
        idGroup: idGroup,
        idMeeting: idMeeting,
        idUser: idUser,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal rapat berhasil dihapus.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      return _mapError(e, stack, 'deleteMeeting');
    }
  }
}
