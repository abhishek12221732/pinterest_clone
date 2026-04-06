import 'package:flutter/material.dart';
import 'dart:math' as math;

class PinterestLoader extends StatefulWidget {
  const PinterestLoader({super.key});

  @override
  State<PinterestLoader> createState() => _PinterestLoaderState();
}

class _PinterestLoaderState extends State<PinterestLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(); // Loops infinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Rotate the entire canvas
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildDot(const Color(0xFFE60023), 0), // Pinterest Red
                  _buildDot(Colors.grey[400]!, 2 * math.pi / 3), // Light Grey
                  _buildDot(Colors.grey[800]!, 4 * math.pi / 3), // Dark Grey
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDot(Color color, double angle) {
    // Math to position the dots in a perfect triangle
    final double radius = 12.0;
    final double x = radius * math.cos(angle);
    final double y = radius * math.sin(angle);

    return Transform.translate(
      offset: Offset(x, y),
      // Math to make them pulse slightly as they rotate
      child: Transform.scale(
        scale: 0.8 + (0.2 * math.sin(_controller.value * 2 * math.pi + angle)),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
