import 'package:flutter/material.dart';

/// Data model representing a Team in the IMPAL application.
class TeamModel {
  final String id;
  final String name;
  final String membersLabel;
  final List<Color> memberColors;
  final String? inviteCode;
  final String? description;

  const TeamModel({
    required this.id,
    required this.name,
    this.membersLabel = 'Team members',
    required this.memberColors,
    this.inviteCode,
    this.description,
  });

  static const List<Color> _palette = [
    Color(0xFFF3A683),
    Color(0xFF786FA6),
    Color(0xFF63CDDA),
    Color(0xFFE77F67),
    Color(0xFF778BEB),
  ];

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    final memberCount = int.tryParse(map['member_count']?.toString() ?? '1') ?? 1;
    final colors = <Color>[];
    for (int i = 0; i < (memberCount > 5 ? 5 : memberCount); i++) {
      colors.add(_palette[i % _palette.length]);
    }
    if (colors.isEmpty) {
      colors.add(_palette[0]);
    }

    return TeamModel(
      id: (map['id_group'] ?? map['id'] ?? '').toString(),
      name: (map['group_name'] ?? map['name'] ?? 'Untitled Team').toString(),
      membersLabel: map['membersLabel']?.toString() ?? '$memberCount members',
      memberColors: colors,
      inviteCode: map['invite_code']?.toString(),
      description: map['description']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'membersLabel': membersLabel,
      'invite_code': inviteCode,
      'description': description,
    };
  }
}
