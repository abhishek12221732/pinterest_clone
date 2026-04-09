import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../domain/pexels_model.dart';

class PinDetailScreen extends StatelessWidget {
  final PexelsPhoto photo;
  final String heroTag;

  const PinDetailScreen({
    super.key,
    required this.photo,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final pinTextColor = Colors.white;
    final pinScaffoldColor = Colors.black;

    return Scaffold(
      backgroundColor: pinScaffoldColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Stacked Image with Overlays
                  Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      GestureDetector(
                        child: Hero(
                          tag: heroTag,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              12,
                              12,
                              12,
                              0,
                            ), // Slightly tighter padding
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CachedNetworkImage(
                                imageUrl: photo.largeImageUrl,
                                fit: BoxFit.contain,
                                // Use the instantly available RAM-cached
                                // grid image (medium) as the placeholder for the Hero animation
                                placeholder: (context, url) =>
                                    CachedNetworkImage(
                                      imageUrl: photo.imageUrl,
                                      fit: BoxFit.contain,
                                    ),
                                // Added a subtle error state just in case
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Overlay 1: Back Button
                      Positioned(
                        top: 24,
                        left: 24, // Tighter to the corner
                        child: _buildImageOverlayButton(
                          context,
                          Icons.chevron_left_rounded,
                          () {
                            context.pop();
                          },
                        ),
                      ),
                      // Overlay 2: Visual Search Button
                      Positioned(
                        bottom: 16,
                        right: 24,
                        child: _buildImageOverlayButton(
                          context,
                          Icons.center_focus_strong_rounded,
                          () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ),
                    ],
                  ),

                  // 2. The Detailed Engagement Row (Refined scaling)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Engagement Icons with Counts
                        Row(
                          children: [
                            _buildEngagementStat(
                              Icons.favorite_border_rounded,
                              '415',
                            ),
                            const SizedBox(width: 8), // Tighter spacing
                            _buildEngagementStat(
                              Icons.chat_bubble_outline_rounded,
                              '1',
                            ),
                            const SizedBox(width: 8),
                            _buildEngagementIcon(Icons.share_outlined),
                            const SizedBox(width: 4),
                            _buildEngagementIcon(Icons.more_horiz_rounded),
                          ],
                        ),
                        // Prominent Red Save Button (Less rounded)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE60023),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            // REDUCED BORDER RADIUS: From 24 down to 14 to match the screenshot
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => HapticFeedback.heavyImpact(),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Creator and Comment Section (Scaled down)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // SMALLER AVATAR: 44 -> 36
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=100',
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // SMALLER FONT: 17 -> 15
                            const Text(
                              'Roberto Trufelli',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // SMALLER FONT: 16 -> 15, lighter weight
                        Text(
                          '"Мне нравится! ❤️ Спасибо" ... View comment',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'More to explore',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. More To Explore Grid (Using modern SliverMasonryGrid)
          _buildMoreToExploreGrid(context),
        ],
      ),
    );
  }

  // Overlay button (Slightly smaller)
  Widget _buildImageOverlayButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 40,
      height: 40, // Scaled down from 44
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24), // Scaled down from 28
        onPressed: onPressed,
      ),
    );
  }

  // Side-by-side icon and count
  Widget _buildEngagementStat(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEngagementIcon(icon),
        const SizedBox(width: 2),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ), // Scaled down
        ),
      ],
    );
  }

  // Smaller icons
  Widget _buildEngagementIcon(IconData icon) {
    return InkWell(
      onTap: () => HapticFeedback.lightImpact(),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: Colors.white, size: 24), // Scaled down from 28
      ),
    );
  }

  Widget _buildMoreToExploreGrid(BuildContext context) {
    final List<Map<String, String>> _mockDiscoveryImages = [
      {
        'image':
            'https://images.pexels.com/photos/1926769/pexels-photo-1926769.jpeg?auto=compress&cs=tinysrgb&w=400',
      },
      {
        'image':
            'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=400',
      },
      {
        'image':
            'https://images.pexels.com/photos/4125661/pexels-photo-4125661.jpeg?auto=compress&cs=tinysrgb&w=400',
      },
      {
        'image':
            'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400',
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childCount: _mockDiscoveryImages.length,
        itemBuilder: (context, index) {
          final discoveryImage = _mockDiscoveryImages[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: discoveryImage['image']!,
              memCacheWidth: 400,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
