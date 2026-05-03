import 'dart:ui';
import 'package:flutter/material.dart';

enum GlassLevel { level1, level2, level3, level4 }
enum GlassTint { none, success, warning, danger, info, purple }

class GlassCard extends StatelessWidget {
  final Widget child;
  final GlassLevel level;
  final GlassTint tint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.level = GlassLevel.level2,
    this.tint = GlassTint.none,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    double blurSigma = 10.0;
    Color bgColor = Colors.white.withOpacity(0.60);
    Color borderColor = Colors.white.withOpacity(0.70);
    List<BoxShadow> shadows = [];

    if (tint == GlassTint.none) {
      switch (level) {
        case GlassLevel.level1:
          blurSigma = 6.0;
          bgColor = Colors.white.withOpacity(0.50);
          borderColor = Colors.white.withOpacity(0.60);
          shadows = [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
          ];
          break;
        case GlassLevel.level2:
          blurSigma = 10.0;
          bgColor = Colors.white.withOpacity(0.60);
          borderColor = Colors.white.withOpacity(0.70);
          shadows = [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ];
          break;
        case GlassLevel.level3:
          blurSigma = 15.0;
          bgColor = Colors.white.withOpacity(0.70);
          borderColor = Colors.white.withOpacity(0.80);
          shadows = [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4)),
          ];
          break;
        case GlassLevel.level4:
          blurSigma = 20.0;
          bgColor = Colors.white.withOpacity(0.75);
          borderColor = Colors.white.withOpacity(0.85);
          shadows = [
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 32, offset: const Offset(0, 12)),
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
          ];
          break;
      }
    } else {
      blurSigma = 10.0;
      switch (tint) {
        case GlassTint.success:
          bgColor = const Color(0xFF86EFAC).withOpacity(0.35);
          borderColor = const Color(0xFF86EFAC).withOpacity(0.50);
          shadows = [BoxShadow(color: const Color(0xFF86EFAC).withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))];
          break;
        case GlassTint.warning:
          bgColor = const Color(0xFFFED7AA).withOpacity(0.35);
          borderColor = const Color(0xFFFED7AA).withOpacity(0.50);
          shadows = [BoxShadow(color: const Color(0xFFFED7AA).withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))];
          break;
        case GlassTint.danger:
          bgColor = const Color(0xFFFCA5A5).withOpacity(0.35);
          borderColor = const Color(0xFFFCA5A5).withOpacity(0.50);
          shadows = [BoxShadow(color: const Color(0xFFFCA5A5).withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))];
          break;
        case GlassTint.info:
          bgColor = const Color(0xFF93C5FD).withOpacity(0.35);
          borderColor = const Color(0xFF93C5FD).withOpacity(0.50);
          shadows = [BoxShadow(color: const Color(0xFF93C5FD).withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))];
          break;
        case GlassTint.purple:
          bgColor = const Color(0xFFD8B4FE).withOpacity(0.35);
          borderColor = const Color(0xFFD8B4FE).withOpacity(0.50);
          shadows = [BoxShadow(color: const Color(0xFFD8B4FE).withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))];
          break;
        case GlassTint.none: break;
      }
      shadows.add(BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)));
    }

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: this.backgroundColor ?? bgColor,
        border: Border.all(color: this.borderColor ?? borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: cardContent,
        ),
      ),
    );
  }
}
