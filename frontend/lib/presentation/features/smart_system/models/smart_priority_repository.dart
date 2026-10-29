import 'package:flutter/material.dart';
import 'smart_priority_model.dart';

class SmartPriorityRepository extends ChangeNotifier {
  static final SmartPriorityRepository instance =
      SmartPriorityRepository._internal();
  factory SmartPriorityRepository() => instance;

  SmartPriorityRepository._internal() {
    _initDefaultData();
  }

  late List<SmartPriorityModel> _items;

  List<SmartPriorityModel> get items => List.unmodifiable(_items);

  SmartPriorityModel? get topPriority =>
      _items.isNotEmpty ? _items.first : null;

  void _initDefaultData() {
    _items = [
      const SmartPriorityModel(
        id: 'sp-1',
        rank: 1,
        rankLabel: '#1 CRITICAL PRIORITY',
        title: 'AI Major Project - Sprint 2',
        categoryTag: 'Laporan • Kelompok',
        score: 87.5,
        level: SmartPriorityLevel.high,
        timeLeftText: '1 Day (Urgent)',
        courseWeightText: '35% (High)',
        deadlineParam: FuzzifiedParameter(
          label: 'Time Left (Deadline): 1 Day (24 Hours)',
          valueText: '1 Day (24 Hours)',
          degree: 0.85,
          degreeLabel: 'μ = 0.85 (Urgent)',
          accentColor: Color(0xFFFF5E4D),
          membershipValues: {
            'Urgent': 0.85,
            'Moderate': 0.15,
            'Relaxed': 0.00,
          },
        ),
        courseWeightParam: FuzzifiedParameter(
          label: 'Course Grade Weight: 35% (High)',
          valueText: '35% (High)',
          degree: 0.70,
          degreeLabel: 'μ = 0.70 (High)',
          accentColor: Color(0xFFF5A623),
          membershipValues: {
            'High': 0.70,
            'Medium': 0.30,
            'Low': 0.00,
          },
        ),
        aggregationAreaText: 'Critical Priority (0.70)',
        reasonExplanation:
            'The Mamdani Fuzzy Inference Engine evaluated a critical proximity to deadline (1 Day remaining, μ=0.85) combined with a high academic syllabus weight (35%, μ=0.70). Applying Mamdani Rule #4, the resulting defuzzified Center of Gravity output is 87.5, placing this task at the top of today\'s study focus.',
      ),
      const SmartPriorityModel(
        id: 'sp-2',
        rank: 2,
        rankLabel: '#2 MODERATE PRIORITY',
        title: 'Bahasa Indonesia Essay Analysis',
        categoryTag: 'Tugas • Individu',
        score: 51.4,
        level: SmartPriorityLevel.medium,
        timeLeftText: '6 Days (Relaxed)',
        courseWeightText: '25% (Medium)',
        deadlineParam: FuzzifiedParameter(
          label: 'Time Left (Deadline): 6 Days (144 Hours)',
          valueText: '6 Days (144 Hours)',
          degree: 0.50,
          degreeLabel: 'μ = 0.50 (Moderate)',
          accentColor: Color(0xFFF5A623),
          membershipValues: {
            'Urgent': 0.10,
            'Moderate': 0.65,
            'Relaxed': 0.25,
          },
        ),
        courseWeightParam: FuzzifiedParameter(
          label: 'Course Grade Weight: 25% (Medium)',
          valueText: '25% (Medium)',
          degree: 0.55,
          degreeLabel: 'μ = 0.55 (Medium)',
          accentColor: Color(0xFFF5A623),
          membershipValues: {
            'High': 0.20,
            'Medium': 0.60,
            'Low': 0.20,
          },
        ),
        aggregationAreaText: 'Moderate Priority (0.50)',
        reasonExplanation:
            'The task has a comfortable buffer before deadline (6 Days, μ=0.50) with medium syllabus contribution (25%, μ=0.55). Fired Mamdani rules output a balanced Center of Gravity crisp score of 51.4.',
      ),
      const SmartPriorityModel(
        id: 'sp-3',
        rank: 3,
        rankLabel: '#3 LOW PRIORITY',
        title: 'IMPAL LMS Quiz Preparation',
        categoryTag: 'Kuis • Individu',
        score: 28.6,
        level: SmartPriorityLevel.low,
        timeLeftText: '14 Days (Extended)',
        courseWeightText: '10% (Low)',
        deadlineParam: FuzzifiedParameter(
          label: 'Time Left (Deadline): 14 Days (336 Hours)',
          valueText: '14 Days (336 Hours)',
          degree: 0.20,
          degreeLabel: 'μ = 0.20 (Relaxed)',
          accentColor: Color(0xFF10B981),
          membershipValues: {
            'Urgent': 0.00,
            'Moderate': 0.15,
            'Relaxed': 0.85,
          },
        ),
        courseWeightParam: FuzzifiedParameter(
          label: 'Course Grade Weight: 10% (Low)',
          valueText: '10% (Low)',
          degree: 0.25,
          degreeLabel: 'μ = 0.25 (Low)',
          accentColor: Color(0xFF10B981),
          membershipValues: {
            'High': 0.05,
            'Medium': 0.20,
            'Low': 0.75,
          },
        ),
        aggregationAreaText: 'Low Priority (0.25)',
        reasonExplanation:
            'The deadline is over two weeks away with minor grade weighting (10%). Mamdani Defuzzification calculates an output of 28.6, recommending completion after critical assignments are submitted.',
      ),
    ];
  }

  int getCount(SmartPriorityLevel? level) {
    if (level == null) return _items.length;
    return _items.where((i) => i.level == level).length;
  }

  List<SmartPriorityModel> getFiltered(SmartPriorityLevel? level) {
    if (level == null) return items;
    return _items.where((i) => i.level == level).toList();
  }
}

