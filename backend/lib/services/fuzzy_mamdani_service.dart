import 'dart:math' as math;

class FuzzyRuleMatch {
  final int ruleNumber;
  final String timeTerm;
  final String weightTerm;
  final String outputLevel;
  final double strength;

  const FuzzyRuleMatch({
    required this.ruleNumber,
    required this.timeTerm,
    required this.weightTerm,
    required this.outputLevel,
    required this.strength,
  });

  Map<String, dynamic> toJson() {
    return {
      'ruleNumber': ruleNumber,
      'timeTerm': timeTerm,
      'weightTerm': weightTerm,
      'outputLevel': outputLevel,
      'strength': double.parse(strength.toStringAsFixed(2)),
    };
  }
}

class FuzzyParameterDetail {
  final String label;
  final String valueText;
  final double degree;
  final String degreeLabel;
  final String dominantTerm;
  final Map<String, double> membershipValues;

  const FuzzyParameterDetail({
    required this.label,
    required this.valueText,
    required this.degree,
    required this.degreeLabel,
    required this.dominantTerm,
    required this.membershipValues,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'valueText': valueText,
      'degree': double.parse(degree.toStringAsFixed(2)),
      'degreeLabel': degreeLabel,
      'dominantTerm': dominantTerm,
      'membershipValues': membershipValues.map(
        (k, v) => MapEntry(k, double.parse(v.toStringAsFixed(2))),
      ),
    };
  }
}

class FuzzyEvaluationResult {
  final double score;
  final String level; // HIGH | MEDIUM | LOW (<= 6 chars for task.priority VARCHAR(6))
  final String timeLeftText;
  final String courseWeightText;
  final FuzzyParameterDetail deadlineParam;
  final FuzzyParameterDetail courseWeightParam;
  final String aggregationAreaText;
  final String reasonExplanation;
  final List<FuzzyRuleMatch> firedRules;

  const FuzzyEvaluationResult({
    required this.score,
    required this.level,
    required this.timeLeftText,
    required this.courseWeightText,
    required this.deadlineParam,
    required this.courseWeightParam,
    required this.aggregationAreaText,
    required this.reasonExplanation,
    required this.firedRules,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'level': level,
      'timeLeftText': timeLeftText,
      'courseWeightText': courseWeightText,
      'deadlineParam': deadlineParam.toJson(),
      'courseWeightParam': courseWeightParam.toJson(),
      'aggregationAreaText': aggregationAreaText,
      'reasonExplanation': reasonExplanation,
      'firedRules': firedRules.map((r) => r.toJson()).toList(),
    };
  }
}

/// Mamdani Min-Max Fuzzy Inference Engine with Centroid (CoG) Defuzzification
/// and Explainable AI (XAI) output matching the Flutter SmartPriorityModel.
class FuzzyMamdaniService {
  static double _round1(double v) => (v * 10).round() / 10.0;
  static double _round2(double v) => (v * 100).round() / 100.0;

  static double _trapezoid(double x, double a, double b, double c, double d) {
    if (x < a || x > d) return 0.0;
    if (x >= b && x <= c) return 1.0;
    if (x < b) {
      if (b == a) return 1.0;
      return ((x - a) / (b - a)).clamp(0.0, 1.0);
    }
    if (d == c) return 1.0;
    return ((d - x) / (d - c)).clamp(0.0, 1.0);
  }

  static double _triangle(double x, double a, double b, double c) {
    return _trapezoid(x, a, b, b, c);
  }

  static FuzzyEvaluationResult evaluate({
    required DateTime deadline,
    required double gradeWeight,
    DateTime? now,
  }) {
    final referenceNow = now ?? DateTime.now();
    final diffMinutes = deadline.difference(referenceNow).inMinutes;
    final rawHours = diffMinutes / 60.0;
    final hours = rawHours.clamp(0.0, 336.0);
    final weight = gradeWeight.clamp(0.0, 100.0);

    // ─── 1. FUZZIFICATION ───────────────────────────────────────────────────
    // Input 1: Time Left (hours remaining, clamped 0..336h)
    final timeMu = <String, double>{
      'Urgent': _round2(_trapezoid(hours, 0.0, 0.0, 12.0, 92.0)),
      'Moderate': _round2(_triangle(hours, 12.0, 120.0, 240.0)),
      'Relaxed': _round2(_trapezoid(hours, 120.0, 288.0, 336.0, 336.0)),
    };

    // Input 2: Course Grade Weight (0..100%)
    final weightMu = <String, double>{
      'Low': _round2(_trapezoid(weight, 0.0, 0.0, 10.0, 25.0)),
      'Medium': _round2(_triangle(weight, 10.0, 25.0, 40.0)),
      'High': _round2(_trapezoid(weight, 25.0, 40.0, 100.0, 100.0)),
    };

    // ─── 2. MAMDANI RULE BASE (3 x 3 = 9 RULES) ─────────────────────────────
    const rules = <({int no, String time, String weight, String out})>[
      (no: 1, time: 'Urgent', weight: 'High', out: 'HIGH'),
      (no: 2, time: 'Urgent', weight: 'Medium', out: 'HIGH'),
      (no: 3, time: 'Urgent', weight: 'Low', out: 'MEDIUM'),
      (no: 4, time: 'Moderate', weight: 'High', out: 'HIGH'),
      (no: 5, time: 'Moderate', weight: 'Medium', out: 'MEDIUM'),
      (no: 6, time: 'Moderate', weight: 'Low', out: 'LOW'),
      (no: 7, time: 'Relaxed', weight: 'High', out: 'MEDIUM'),
      (no: 8, time: 'Relaxed', weight: 'Medium', out: 'LOW'),
      (no: 9, time: 'Relaxed', weight: 'Low', out: 'LOW'),
    ];

    var alphaLow = 0.0;
    var alphaMedium = 0.0;
    var alphaHigh = 0.0;
    final firedRules = <FuzzyRuleMatch>[];

    for (final rule in rules) {
      final strength = math.min(
        timeMu[rule.time] ?? 0.0,
        weightMu[rule.weight] ?? 0.0,
      );
      if (strength > 0.0) {
        firedRules.add(
          FuzzyRuleMatch(
            ruleNumber: rule.no,
            timeTerm: rule.time,
            weightTerm: rule.weight,
            outputLevel: rule.out,
            strength: strength,
          ),
        );
        if (rule.out == 'HIGH') {
          alphaHigh = math.max(alphaHigh, strength);
        } else if (rule.out == 'MEDIUM') {
          alphaMedium = math.max(alphaMedium, strength);
        } else {
          alphaLow = math.max(alphaLow, strength);
        }
      }
    }

    firedRules.sort((a, b) => b.strength.compareTo(a.strength));

    // ─── 3. AGGREGATION & CENTROID CoG DEFUZZIFICATION (z = 0..100) ──────────
    var numerator = 0.0;
    var denominator = 0.0;

    for (var z = 0; z <= 100; z++) {
      final zd = z.toDouble();
      final muLow = math.min(alphaLow, _trapezoid(zd, 0.0, 0.0, 20.0, 45.0));
      final muMed = math.min(alphaMedium, _triangle(zd, 25.0, 50.0, 75.0));
      final muHigh = math.min(alphaHigh, _trapezoid(zd, 55.0, 80.0, 100.0, 100.0));
      final aggregated = math.max(muLow, math.max(muMed, muHigh));

      numerator += zd * aggregated;
      denominator += aggregated;
    }

    final score = denominator > 0 ? _round1(numerator / denominator) : 50.0;

    final String level;
    if (score >= 65.0) {
      level = 'HIGH';
    } else if (score >= 38.0) {
      level = 'MEDIUM';
    } else {
      level = 'LOW';
    }

    // ─── 4. XAI EXPLANATION FORMATTING ──────────────────────────────────────
    final domTimeEntry = timeMu.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final domWeightEntry = weightMu.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    final formattedDuration = _formatDurationText(diffMinutes);
    final timeLeftText = rawHours < 0
        ? '$formattedDuration (Overdue)'
        : '$formattedDuration (${domTimeEntry.key})';
    final roundedWeight = weight % 1 == 0
        ? '${weight.toInt()}%'
        : '${_round1(weight)}%';
    final courseWeightText = '$roundedWeight (${domWeightEntry.key})';

    final deadlineParam = FuzzyParameterDetail(
      label: 'Time Left (Deadline): $formattedDuration',
      valueText: formattedDuration,
      degree: domTimeEntry.value,
      degreeLabel:
          'μ = ${domTimeEntry.value.toStringAsFixed(2)} (${domTimeEntry.key})',
      dominantTerm: domTimeEntry.key,
      membershipValues: timeMu,
    );

    final courseWeightParam = FuzzyParameterDetail(
      label: 'Course Grade Weight: $courseWeightText',
      valueText: courseWeightText,
      degree: domWeightEntry.value,
      degreeLabel:
          'μ = ${domWeightEntry.value.toStringAsFixed(2)} (${domWeightEntry.key})',
      dominantTerm: domWeightEntry.key,
      membershipValues: weightMu,
    );

    final String areaTitle;
    final double areaAlpha;
    if (level == 'HIGH') {
      areaTitle = 'Critical Priority';
      areaAlpha = alphaHigh;
    } else if (level == 'MEDIUM') {
      areaTitle = 'Moderate Priority';
      areaAlpha = alphaMedium;
    } else {
      areaTitle = 'Low Priority';
      areaAlpha = alphaLow;
    }
    final aggregationAreaText = '$areaTitle (${areaAlpha.toStringAsFixed(2)})';

    final topRule = firedRules.isNotEmpty ? firedRules.first : null;
    final ruleRef = topRule != null ? 'Mamdani Rule #${topRule.ruleNumber}' : 'Mamdani rules';
    final overdueNote = rawHours < 0
        ? 'The deadline has passed, triggering maximum deadline urgency. '
        : '';
    final reasonExplanation =
        '${overdueNote}The Mamdani Fuzzy Inference Engine evaluated deadline proximity ($formattedDuration, μ=${domTimeEntry.value.toStringAsFixed(2)} ${domTimeEntry.key}) and grade weight ($roundedWeight, μ=${domWeightEntry.value.toStringAsFixed(2)} ${domWeightEntry.key}). Applying $ruleRef, Centroid (CoG) defuzzification yields a priority score of ${score.toStringAsFixed(1)} ($level).';

    return FuzzyEvaluationResult(
      score: score,
      level: level,
      timeLeftText: timeLeftText,
      courseWeightText: courseWeightText,
      deadlineParam: deadlineParam,
      courseWeightParam: courseWeightParam,
      aggregationAreaText: aggregationAreaText,
      reasonExplanation: reasonExplanation,
      firedRules: firedRules,
    );
  }

  static String _formatDurationText(int diffMinutes) {
    if (diffMinutes < 0) {
      final absHours = diffMinutes.abs() ~/ 60;
      if (absHours >= 24) {
        final days = (absHours / 24).ceil();
        return 'Overdue by $days ${days == 1 ? 'Day' : 'Days'}';
      }
      final h = math.max(1, absHours);
      return 'Overdue by $h ${h == 1 ? 'Hour' : 'Hours'}';
    }
    if (diffMinutes < 60) {
      return '${math.max(1, diffMinutes)} Minutes';
    }
    final hours = (diffMinutes / 60).round();
    if (hours < 48) {
      final days = (hours / 24).floor();
      if (days >= 1) {
        return '$days ${days == 1 ? 'Day' : 'Days'} ($hours Hours)';
      }
      return '$hours ${hours == 1 ? 'Hour' : 'Hours'}';
    }
    final days = (hours / 24).round();
    return '$days Days ($hours Hours)';
  }
}
