import 'package:flutter/material.dart';

/// Informational callout banner with coral accent stripe.
class AuthNoticeBanner extends StatelessWidget {
  final String title;
  final String message;
  final String? highlightText;

  const AuthNoticeBanner({
    super.key,
    required this.title,
    required this.message,
    this.highlightText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(
            color: Color(0xFFFA6144),
            width: 3.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: Color(0xFFFA6144),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  TextSpan(
                    text: message,
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 11.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  if (highlightText != null) ...[
                    TextSpan(
                      text: highlightText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

