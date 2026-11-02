import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_context.dart';

class NotificationBanner extends StatelessWidget {
  const NotificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(14),
        vertical: context.rSpacing(11),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2333),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C3A54),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: context.rIcon(32),
            height: context.rIcon(32),
            decoration: BoxDecoration(
              color: const Color(0xFF253B64),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF3B5685),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.access_time_filled_rounded,
              size: context.rIcon(16),
              color: const Color(0xFF60A5FA),
            ),
          ),
          SizedBox(width: context.rSpacing(11)),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: context.rFont(12, min: 10.5, max: 13.5),
                  color: const Color(0xFFBFDBFE),
                  height: 1.35,
                ),
                children: const [
                  TextSpan(
                    text: 'Background Scheduler Active • ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: 'Alerts at D-3, D-1 & 30 mins before classes.',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF93C5FD),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
