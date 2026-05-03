import 'package:flutter/material.dart';

enum TileColor { blue, green, amber, purple }

class QuickActionTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final TileColor color;
  final VoidCallback? onClick;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    switch (color) {
      case TileColor.blue:
        bgColor = const Color(0xFFDBEAFE).withOpacity(0.70); // blue-100/70
        borderColor = const Color(0xFFBFDBFE); // blue-200
        textColor = const Color(0xFF2563EB); // blue-600
        break;
      case TileColor.green:
        bgColor = const Color(0xFFD1FAE5).withOpacity(0.70); // emerald-100/70
        borderColor = const Color(0xFFA7F3D0); // emerald-200
        textColor = const Color(0xFF059669); // emerald-600
        break;
      case TileColor.amber:
        bgColor = const Color(0xFFFEF3C7).withOpacity(0.70); // amber-100/70
        borderColor = const Color(0xFFFDE68A); // amber-200
        textColor = const Color(0xFFD97706); // amber-600
        break;
      case TileColor.purple:
        bgColor = const Color(0xFFF3E8FF).withOpacity(0.70); // purple-100/70
        borderColor = const Color(0xFFE9D5FF); // purple-200
        textColor = const Color(0xFF9333EA); // purple-600
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.60),
        border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onClick,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: IconTheme(
                    data: IconThemeData(color: textColor, size: 18),
                    child: icon,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155), // slate-700
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
