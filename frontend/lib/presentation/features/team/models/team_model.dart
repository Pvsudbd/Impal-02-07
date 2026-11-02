import 'package:flutter/material.dart';

/// Data model representing a Team in the IMPAL application.
class TeamModel {
  final String id;
  final String name;
  final String membersLabel;
  final List<Color> memberColors;

  const TeamModel({
    required this.id,
    required this.name,
    this.membersLabel = 'Team members',
    required this.memberColors,
  });
}
