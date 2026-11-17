import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
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

        if (fetched.isNotEmpty) {
          _teams = fetched;
          teamsNotifier.value = List.unmodifiable(_teams);
        }
      }
    } catch (e) {
      debugPrint('[TEAM_REPO] fetchTeamsFromApi error: $e');
    }
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
