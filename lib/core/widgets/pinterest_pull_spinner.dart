import 'package:flutter/material.dart';
import 'dart:math' as math;

class PinterestFourDotSpinner extends StatefulWidget {
  final double percentage; // 0.0 to 1.0 based on how far the user has pulled
  final bool isRefreshing; // True when the network call is actively running

  const PinterestFourDotSpinner({
    super.key,
    required this.percentage,
    required this.isRefreshing,
  });

  @override
  State<PinterestFourDotSpinner> createState() =>
      _PinterestFourDotSpinnerState();
}

class _PinterestFourDotSpinnerState extends State<PinterestFourDotSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1-second rotation cycle
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didUpdateWidget(PinterestFourDotSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we trigger the refresh, start spinning infinitely
    if (widget.isRefreshing && !_controller.isAnimating) {
      _controller.repeat();
    }
    // If the refresh finishes, stop spinning
    else if (!widget.isRefreshing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF333333) : Colors.white;
    // Exactly uniform Pinterest grey for all dots
    final dotColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    // As the user pulls down, the spinner rotates slightly
    final pullRotation = widget.percentage * math.pi;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // When actively refreshing, use the animation controller. Otherwise, use the pull drag rotation.
        final spinRotation = _controller.value * 2 * math.pi;
        final totalRotation = widget.isRefreshing ? spinRotation : pullRotation;

        return Transform.rotate(
          angle: totalRotation,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              // Wrap automatically creates a perfect 2x2 grid when given restricted space
              child: SizedBox(
                width: 20, // 8px dot + 4px space + 8px dot
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildDot(dotColor), // The signature Pinterest Red dot
                    _buildDot(dotColor),
                    _buildDot(dotColor),
                    _buildDot(dotColor),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper to build the individual dots
  Widget _buildDot(Color color) {
    // If refreshing, keep them at full size.
    // If pulling, scale them up from 0 to full size based on pull percentage.
    final scale = widget.isRefreshing ? 1.0 : widget.percentage;

    return Transform.scale(
      scale: scale < 0.2
          ? 0.0
          : scale, // They "pop" in nicely after a slight pull
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
