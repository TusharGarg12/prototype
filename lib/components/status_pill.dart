import 'package:flutter/material.dart';

enum StatusVariant { success, warning, danger, info, purple }

class StatusPill extends StatelessWidget {
  final String text;
  final StatusVariant variant;
  final bool showDot;

  const StatusPill({
    super.key,
    required this.text,
    required this.variant,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    Color dotColor;

    switch (variant) {
      case StatusVariant.success:
        bgColor = const Color(0xFFD1FAE5).withOpacity(0.70);
        borderColor = const Color(0xFFA7F3D0);
        textColor = const Color(0xFF065F46); // emerald-800
        dotColor = const Color(0xFF10B981); // emerald-500
        break;
      case StatusVariant.warning:
        bgColor = const Color(0xFFFEF3C7).withOpacity(0.70);
        borderColor = const Color(0xFFFDE68A);
        textColor = const Color(0xFF92400E); // amber-800
        dotColor = const Color(0xFFF59E0B); // amber-500
        break;
      case StatusVariant.danger:
        bgColor = const Color(0xFFFFE4E6).withOpacity(0.70);
        borderColor = const Color(0xFFFECDD3);
        textColor = const Color(0xFF9F1239); // rose-800
        dotColor = const Color(0xFFF43F5E); // rose-500
        break;
      case StatusVariant.info:
        bgColor = const Color(0xFFDBEAFE).withOpacity(0.70);
        borderColor = const Color(0xFFBFDBFE);
        textColor = const Color(0xFF1E40AF); // blue-800
        dotColor = const Color(0xFF3B82F6); // blue-500
        break;
      case StatusVariant.purple:
        bgColor = const Color(0xFFF3E8FF).withOpacity(0.70);
        borderColor = const Color(0xFFE9D5FF);
        textColor = const Color(0xFF6B21A8); // purple-800
        dotColor = const Color(0xFFA855F7); // purple-500
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: [
                  BoxShadow(color: dotColor.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2, // tracking-tight
            ),
          ),
        ],
      ),
    );
  }
}
