import 'package:flutter/material.dart';

/// Model representing a team member available for task assignment.
class TeamMemberModel {
  final String id;
  final String name;
  final Color avatarColor;

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.avatarColor,
  });

  /// Default mock members matching Figma design specifications
  static const List<TeamMemberModel> defaultMembers = [
    TeamMemberModel(
      id: 'member_1',
      name: 'Ahmad Sahroni',
      avatarColor: Color(0xFF63CDDA),
    ),
    TeamMemberModel(
      id: 'member_2',
      name: 'Muhammad Kafi Rijal',
      avatarColor: Color(0xFF786FA6),
    ),
    TeamMemberModel(
      id: 'member_3',
      name: 'Yoga Perkakas',
      avatarColor: Color(0xFFF3A683),
    ),
  ];
}

