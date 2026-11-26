import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import 'team_member_model.dart';
import 'team_model.dart';

/// Centralized repository for managing teams in the application.
class TeamRepository {
  static final TeamRepository _instance = TeamRepository._internal();
  factory TeamRepository() => _instance;

  TeamRepository._internal() {
    _teams = List<TeamModel>.from(_defaultTeams);
  }

  static const List<TeamModel> _defaultTeams = [
    TeamModel(
      id: '1',
      name: 'IMPAL Team',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFFE77F67),
        Color(0xFF778BEB),
      ],
    ),
    TeamModel(
      id: '2',
      name: 'IUM Team',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
      ],
    ),
    TeamModel(
      id: '3',
      name: 'ICT Project Team',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFFE77F67),
      ],
    ),
    TeamModel(
      id: '4',
      name: 'AI Project Team',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFF778BEB),
      ],
    ),
  ];

  late List<TeamModel> _teams;
  final ValueNotifier<List<TeamModel>> teamsNotifier =
      ValueNotifier<List<TeamModel>>([]);

  /// Returns an unmodifiable list of joined teams.
  List<TeamModel> get teams => List.unmodifiable(_teams);

  /// Returns the names of all currently joined teams.
  List<String> get joinedTeamNames => _teams.map((t) => t.name).toList();

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') ?? prefs.getString('jwt_token');
    } catch (_) {
      return null;
    }
  }

  /// Sinkronisasi daftar team dari Backend API (GET /api/groups)
  Future<void> fetchTeamsFromApi() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final res = await ApiClient.get('/api/groups', token: token);
      if (res['status'] == 'success' && res['data'] is List) {
        final List<dynamic> raw = res['data'];
        final fetched = raw
            .map((item) => TeamModel.fromMap(item as Map<String, dynamic>))
            .toList();

        // Selalu sinkronisasikan _teams dengan data milik akun yang sedang aktif
        _teams = fetched;
        teamsNotifier.value = List.unmodifiable(_teams);
      }
    } catch (e) {
      debugPrint('[TEAM_REPO] fetchTeamsFromApi error: $e');
    }
  }

  /// Membersihkan data tim di memori saat logout
  void clear() {
    _teams = [];
    _cachedMembers.clear();
    teamsNotifier.value = [];
  }

  final Map<String, List<TeamMemberModel>> _cachedMembers = {};

  /// Mengambil daftar anggota grup dari Backend (GET /api/groups/<idGroup>)
  Future<List<TeamMemberModel>> fetchGroupMembers(
    String teamCodeOrId, {
    String? fallbackUserName,
  }) async {
    if (_teams.isEmpty) {
      await fetchTeamsFromApi();
    }

    String targetId = teamCodeOrId.trim();
    final cleanInput = teamCodeOrId.trim().toLowerCase();
    final matchedTeam = _teams
        .where((t) =>
            t.id.toLowerCase() == cleanInput ||
            (t.inviteCode != null &&
                t.inviteCode!.trim().toLowerCase() == cleanInput) ||
            t.name.trim().toLowerCase() == cleanInput)
        .firstOrNull;
    if (matchedTeam != null) {
      targetId = matchedTeam.id;
    }

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final encodedTarget = Uri.encodeComponent(targetId);
        final res = await ApiClient.get('/api/groups/$encodedTarget', token: token);
        debugPrint('[TEAM_REPO] fetchGroupMembers res: $res');
        if (res['status'] == 'success' && res['data'] is Map<String, dynamic>) {
          final data = res['data'] as Map<String, dynamic>;
          if (data['members'] is List) {
            final List<dynamic> rawMembers = data['members'];
            const palette = [
              Color(0xFF63CDDA),
              Color(0xFF786FA6),
              Color(0xFFF3A683),
              Color(0xFFE77F67),
              Color(0xFF778BEB),
            ];

            final members = <TeamMemberModel>[];
            for (int i = 0; i < rawMembers.length; i++) {
              final m = rawMembers[i] as Map<String, dynamic>;
              final name = (m['name'] ?? 'Member').toString();
              final id =
                  (m['id_user'] ?? m['id_member'] ?? 'member_$i').toString();
              final rawRole = (m['role'] ?? 'Member').toString();
              final role = rawRole.toLowerCase().contains('lead') ? 'Team Leader' : 'Member';
              final email = (m['email'] ?? '').toString();
              members.add(
                TeamMemberModel(
                  id: id,
                  name: name,
                  avatarColor: palette[i % palette.length],
                  role: role,
                  email: email,
                ),
              );
            }
            if (members.isNotEmpty) {
              _cachedMembers[teamCodeOrId] = members;
              _cachedMembers[targetId] = members;
              final groupMeta = data['group'] is Map<String, dynamic>
                  ? data['group'] as Map<String, dynamic>
                  : data;
              final realId = groupMeta['id_group']?.toString() ?? groupMeta['id']?.toString();
              final inviteCode = groupMeta['invite_code']?.toString();
              final groupName = groupMeta['group_name']?.toString() ?? groupMeta['name']?.toString();
              if (realId != null && realId.isNotEmpty) _cachedMembers[realId] = members;
              if (inviteCode != null && inviteCode.isNotEmpty) _cachedMembers[inviteCode] = members;
              if (groupName != null && groupName.isNotEmpty) _cachedMembers[groupName] = members;

              if (matchedTeam != null) {
                _cachedMembers[matchedTeam.id] = members;
                if (matchedTeam.inviteCode != null) {
                  _cachedMembers[matchedTeam.inviteCode!] = members;
                }
                _cachedMembers[matchedTeam.name] = members;
              }
              return members;
            }
          }
        }
      } catch (e) {
        debugPrint('[TEAM_REPO] fetchGroupMembers error: $e');
      }
    }

    if (_cachedMembers.containsKey(teamCodeOrId) &&
        _cachedMembers[teamCodeOrId]!.isNotEmpty) {
      return _cachedMembers[teamCodeOrId]!;
    }
    if (_cachedMembers.containsKey(targetId) &&
        _cachedMembers[targetId]!.isNotEmpty) {
      return _cachedMembers[targetId]!;
    }

    final fallbackName = (fallbackUserName != null &&
            fallbackUserName.trim().isNotEmpty)
        ? fallbackUserName
        : 'You';
    final isLeader = (matchedTeam != null && matchedTeam.memberColors.length > 1) ? false : true;
    final fallbackList = [
      TeamMemberModel(
        id: 'member_self',
        name: fallbackName,
        avatarColor: const Color(0xFFF3A683),
        role: isLeader ? 'Team Leader' : 'Member',
        email: '$fallbackName@student.telkomuniversity.ac.id'.toLowerCase().replaceAll(' ', '.'),
      ),
    ];
    return fallbackList;
  }

  /// Mengambil anggota grup dari cache memori secara sinkron
  List<TeamMemberModel> getCachedMembers(
    String teamCodeOrId, {
    String? fallbackUserName,
  }) {
    if (_cachedMembers.containsKey(teamCodeOrId) &&
        _cachedMembers[teamCodeOrId]!.isNotEmpty) {
      return _cachedMembers[teamCodeOrId]!;
    }
    final cleanInput = teamCodeOrId.trim().toLowerCase();
    for (final entry in _cachedMembers.entries) {
      if (entry.key.trim().toLowerCase() == cleanInput && entry.value.isNotEmpty) {
        return entry.value;
      }
    }
    final matchedTeam = _teams
        .where((t) =>
            t.id.toLowerCase() == cleanInput ||
            (t.inviteCode != null &&
                t.inviteCode!.trim().toLowerCase() == cleanInput) ||
            t.name.trim().toLowerCase() == cleanInput)
        .firstOrNull;
    if (matchedTeam != null) {
      if (_cachedMembers.containsKey(matchedTeam.id) &&
          _cachedMembers[matchedTeam.id]!.isNotEmpty) {
        return _cachedMembers[matchedTeam.id]!;
      }
      if (matchedTeam.inviteCode != null &&
          _cachedMembers.containsKey(matchedTeam.inviteCode!) &&
          _cachedMembers[matchedTeam.inviteCode!]!.isNotEmpty) {
        return _cachedMembers[matchedTeam.inviteCode!]!;
      }
      if (_cachedMembers.containsKey(matchedTeam.name) &&
          _cachedMembers[matchedTeam.name]!.isNotEmpty) {
        return _cachedMembers[matchedTeam.name]!;
      }
    }
    final fallbackName = (fallbackUserName != null &&
            fallbackUserName.trim().isNotEmpty)
        ? fallbackUserName
        : 'You';
    return [
      TeamMemberModel(
        id: 'member_self',
        name: fallbackName,
        avatarColor: const Color(0xFFF3A683),
        role: 'Team Leader',
        email: '$fallbackName@student.telkomuniversity.ac.id'.toLowerCase().replaceAll(' ', '.'),
      ),
    ];
  }

  /// Panggil API untuk join team via invite code (POST /api/groups/join)
  Future<Map<String, dynamic>> joinTeamApi(String inviteCode) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return {
        'status': 'error',
        'message': 'Authentication token not found. Please log in again.',
      };
    }

    try {
      final res = await ApiClient.post(
        '/api/groups/join',
        {'invite_code': inviteCode.trim().toUpperCase()},
        token: token,
      );

      if (res['status'] == 'success') {
        // Refresh list from API or prepend newly joined group
        if (res['data'] is Map<String, dynamic>) {
          final joinedTeam = TeamModel.fromMap(res['data'] as Map<String, dynamic>);
          // Avoid duplicates
          if (!_teams.any((t) => t.id == joinedTeam.id)) {
            _teams.insert(0, joinedTeam);
            teamsNotifier.value = List.unmodifiable(_teams);
          }
        }
        await fetchTeamsFromApi();
      }

      return res;
    } catch (e) {
      debugPrint('[TEAM_REPO] joinTeamApi error: $e');
      return {
        'status': 'error',
        'message': 'Failed to connect to server: $e',
      };
    }
  }

  /// Panggil API untuk create team baru (POST /api/groups)
  Future<Map<String, dynamic>> createTeamApi({
    required String name,
    String? description,
    String? inviteCode,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return {
        'status': 'error',
        'message': 'Authentication token not found. Please log in again.',
      };
    }

    try {
      final res = await ApiClient.post(
        '/api/groups',
        {
          'group_name': name.trim(),
          'description': description?.trim() ?? '',
          if (inviteCode != null && inviteCode.trim().isNotEmpty)
            'invite_code': inviteCode.trim().toUpperCase(),
        },
        token: token,
      );

      if (res['status'] == 'success') {
        if (res['data'] is Map<String, dynamic>) {
          final createdTeam = TeamModel.fromMap(res['data'] as Map<String, dynamic>);
          _teams.insert(0, createdTeam);
          teamsNotifier.value = List.unmodifiable(_teams);
        }
        await fetchTeamsFromApi();
      }

      return res;
    } catch (e) {
      debugPrint('[TEAM_REPO] createTeamApi error: $e');
      return {
        'status': 'error',
        'message': 'Failed to connect to server: $e',
      };
    }
  }

  /// Adds a new team to the top of the joined teams list.
  void addTeam(TeamModel team) {
    _teams.insert(0, team);
    teamsNotifier.value = List.unmodifiable(_teams);
  }

  /// Resets teams to the default fixture.
  void reset() {
    _teams = List<TeamModel>.from(_defaultTeams);
    teamsNotifier.value = List.unmodifiable(_teams);
  }
}
