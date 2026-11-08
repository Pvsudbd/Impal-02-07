import 'package:flutter/material.dart';

/// Interactive password strength card with 4-bar indicator
/// and real-time security criteria checklist.
class PasswordStrengthCard extends StatelessWidget {
  final String password;

  const PasswordStrengthCard({
    super.key,
    required this.password,
  });

  bool get hasNoSpace => !password.contains(' ');
  bool get hasMinLength => password.length >= 8;
  bool get hasUpperLower =>
      RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password);
  bool get hasNumSymbol =>
      RegExp(r'[0-9]').hasMatch(password) &&
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);

  int get pwdScore {
    if (password.isEmpty) return 0;
    if (!hasNoSpace) return 1;
    int s = (hasMinLength ? 1 : 0) + (hasUpperLower ? 1 : 0) + (hasNumSymbol ? 1 : 0);
    return (password.length >= 12 && s == 3) ? 4 : s;
  }

  String get pwdLabel => switch (pwdScore) {
        1 => 'Weak (33%)',
        2 => 'Medium (66%)',
        3 || 4 => 'Strong (92%)',
        _ => 'Too Weak (0%)',
      };

  Color get pwdColor => switch (pwdScore) {
        1 => const Color(0xFFEF4444),
        2 => const Color(0xFFF59E0B),
        3 || 4 => const Color(0xFF6EE7B7),
        _ => const Color(0xFF6B7280),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D333F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3B4150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PASSWORD STRENGTH',
                style: TextStyle(
                  color: Color(0xFF8E95A5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                pwdLabel,
                style: TextStyle(
                  color: pwdColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Container(
                  height: 4.5,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: (i + 1) <= pwdScore ? pwdColor : const Color(0xFF3F4756),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _reqItem(isMet: hasMinLength, label: 'At least 8 characters long (recommended 12+)'),
          const SizedBox(height: 5),
          _reqItem(isMet: hasUpperLower, label: 'Includes uppercase & lowercase letters'),
          const SizedBox(height: 5),
          _reqItem(isMet: hasNumSymbol, label: 'Includes at least one number and special symbol (#, !, @)'),
          const SizedBox(height: 5),
          _reqItem(isMet: hasNoSpace && password.isNotEmpty, label: 'Cannot contain spaces'),
        ],
      ),
    );
  }

  Widget _reqItem({required bool isMet, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isMet ? const Color(0x3310B981) : const Color(0xFF383F4D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isMet ? const Color(0x6610B981) : const Color(0xFF4B5563)),
          ),
          alignment: Alignment.center,
          child: isMet
              ? const Icon(Icons.check, size: 10, color: Color(0xFF10B981))
              : Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isMet ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
              fontSize: 11,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}

