class PexelsPhoto {
  final int id;
  final String url;
  final String imageUrl;
  final String altText;
  final String photographer;

  PexelsPhoto({
    required this.id,
    required this.url,
    required this.imageUrl,
    required this.altText,
    required this.photographer,
  });

  factory PexelsPhoto.fromJson(Map<String, dynamic> json) {
    return PexelsPhoto(
      id: json['id'],
      url: json['url'],
      // We use the 'large' image size for a good balance of quality and performance
      imageUrl: json['src']['large'],
      altText: json['alt'] ?? 'Pinterest Pin',
      photographer: json['photographer'] ?? 'Unknown',
    );
  }
}
