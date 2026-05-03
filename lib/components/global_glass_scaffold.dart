import 'dart:ui';
import 'package:flutter/material.dart';

class GlobalGlassScaffold extends StatelessWidget {
  final Widget child;

  const GlobalGlassScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient: from-[#f0f4ff] via-[#fef3f8] to-[#f0fdf9]
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F4FF),
              Color(0xFFFEF3F8),
              Color(0xFFF0FDF9),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Blob 1: top-[-80px] left-[-80px] w-[320px] h-[320px] bg-[rgba(147,197,253,0.15)] blur-[160px]
            Positioned(
              top: -80,
              left: -80,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF93C5FD).withOpacity(0.15),
                  ),
                ),
              ),
            ),
            
            // Blob 2: top-[40%] right-[-100px] w-[400px] h-[400px] bg-[rgba(216,180,254,0.12)] blur-[200px]
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD8B4FE).withOpacity(0.12),
                  ),
                ),
              ),
            ),

            // Blob 3: bottom-[-60px] left-[10%] w-[280px] h-[280px] bg-[rgba(134,239,172,0.12)] blur-[140px]
            Positioned(
              bottom: -60,
              left: MediaQuery.of(context).size.width * 0.1,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF86EFAC).withOpacity(0.12),
                  ),
                ),
              ),
            ),

            // Main Content
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
