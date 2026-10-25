import 'package:flutter/material.dart';
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
      name: 'Kelompok - IMPAL',
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
      name: 'Kelompok - IUM',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
      ],
    ),
    TeamModel(
      id: '3',
      name: 'Kelompok - Projek TIK',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFFE77F67),
      ],
    ),
    TeamModel(
      id: '4',
      name: 'Kelompok - KA',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFF778BEB),
      ],
    ),
  ];

  late List<TeamModel> _teams;

  /// Returns an unmodifiable list of joined teams.
  List<TeamModel> get teams => List.unmodifiable(_teams);

  /// Returns the names of all currently joined teams.
  List<String> get joinedTeamNames => _teams.map((t) => t.name).toList();

  /// Adds a new team to the top of the joined teams list.
  void addTeam(TeamModel team) {
    _teams.insert(0, team);
  }

  /// Resets teams to the default fixture.
  void reset() {
    _teams = List<TeamModel>.from(_defaultTeams);
  }
}
