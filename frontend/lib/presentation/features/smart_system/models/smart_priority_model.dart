import 'package:flutter/material.dart';

enum SmartPriorityLevel {
  high,
  medium,
  low,
}

class FuzzifiedParameter {
  final String label;
  final String valueText;
  final double degree;
  final String degreeLabel;
  final Color accentColor;
  final Map<String, double> membershipValues;

  const FuzzifiedParameter({
    required this.label,
    required this.valueText,
    required this.degree,
    required this.degreeLabel,
    required this.accentColor,
    required this.membershipValues,
  });
}

class SmartPriorityModel {
  final String id;
  final int rank;
  final String rankLabel;
  final String title;
  final String categoryTag;
  final double score;
  final SmartPriorityLevel level;
  final String timeLeftText;
  final String courseWeightText;
  final FuzzifiedParameter deadlineParam;
  final FuzzifiedParameter courseWeightParam;
  final String aggregationAreaText;
  final String reasonExplanation;

  const SmartPriorityModel({
    required this.id,
    required this.rank,
    required this.rankLabel,
    required this.title,
    required this.categoryTag,
    required this.score,
    required this.level,
    required this.timeLeftText,
    required this.courseWeightText,
    required this.deadlineParam,
    required this.courseWeightParam,
    required this.aggregationAreaText,
    required this.reasonExplanation,
  });

  Color get levelColor {
    switch (level) {
      case SmartPriorityLevel.high:
        return const Color(0xFFFF5E4D);
      case SmartPriorityLevel.medium:
        return const Color(0xFFFBBF24);
      case SmartPriorityLevel.low:
        return const Color(0xFF6EE7B7);
    }
  }

  Color get levelTextColor {
    switch (level) {
      case SmartPriorityLevel.high:
        return Colors.white;
      case SmartPriorityLevel.medium:
        return const Color(0xFF1F2937);
      case SmartPriorityLevel.low:
        return const Color(0xFF064E3B);
    }
  }

  String get levelLabel {
    switch (level) {
      case SmartPriorityLevel.high:
        return 'HIGH';
      case SmartPriorityLevel.medium:
        return 'MEDIUM';
      case SmartPriorityLevel.low:
        return 'LOW';
    }
  }
}

