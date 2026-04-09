import 'package:flutter/material.dart';

class PexelsPhoto {
  final int id;
  final String url;
  final String imageUrl;      // Medium size — for grid thumbnails
  final String largeImageUrl; // Large size — for detail screen
  final String altText;
  final String photographer;
  final int width;
  final int height;
  final Color avgColor;

  PexelsPhoto({
    required this.id,
    required this.url,
    required this.imageUrl,
    required this.largeImageUrl,
    required this.altText,
    required this.photographer,
    required this.width,
    required this.height,
    required this.avgColor,
  });

  /// The aspect ratio of the original image (width / height).
  double get aspectRatio => width / height;

  factory PexelsPhoto.fromJson(Map<String, dynamic> json) {
    // Parse the hex color string (e.g. "#6E633A") from the API
    final hexColor = (json['avg_color'] as String? ?? '#888888')
        .replaceFirst('#', '');
    final colorValue = int.parse('FF$hexColor', radix: 16);

    return PexelsPhoto(
      id: json['id'],
      url: json['url'],
      // 'medium' (350px wide) for the grid — perfect for a 2-column layout.
      // Dramatically lighter than 'large' (940px wide).
      imageUrl: json['src']['medium'],
      // 'large' for the detail/full-screen view
      largeImageUrl: json['src']['large'],
      altText: json['alt'] ?? 'Pinterest Pin',
      photographer: json['photographer'] ?? 'Unknown',
      width: json['width'] ?? 400,
      height: json['height'] ?? 600,
      avgColor: Color(colorValue),
    );
  }
}
