import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../domain/home_provider.dart';
import '../domain/pexels_model.dart';
import '../../../core/widgets/pinterest_loader.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/widgets/pinterest_pull_spinner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.secondary;
    
    // Define the exact query strings for each tab
    final categories = ['All', 'UI Design', 'Architecture', 'Motivation'];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          titleSpacing: 0,
          title: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorColor: textColor,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: textColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'UI Design'),
              Tab(text: 'Architecture'),
              Tab(text: 'Motivation'),
              Tab(icon: Icon(Icons.tune_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // We pass the specific category to each tab view!
            _buildTabContent(context, ref, categories[0], textColor),
            _buildTabContent(context, ref, categories[1], textColor),
            _buildTabContent(context, ref, categories[2], textColor),
            _buildTabContent(context, ref, categories[3], textColor),
            const Center(child: Text('Customize your home feed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  // A helper method to build the content for a specific tab
  Widget _buildTabContent(BuildContext context, WidgetRef ref, String category, Color iconColor) {
    final feedState = ref.watch(homeFeedProvider(category));

    return feedState.when(
      data: (photos) => CustomScrollView(
        // AlwaysScrollable is required so you can pull down even if the grid isn't full
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // THE MAGIC: A fully customizable refresh sliver
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              return ref.refresh(homeFeedProvider(category).future);
            },
            // The builder exposes exactly how far the user has pulled down
            builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
              // Calculate percentage pulled (0.0 to 1.0)
              final percentage = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
              
              // Determine if the network request is actively running
              final isActivelyRefreshing = refreshState == RefreshIndicatorMode.refresh || 
                                           refreshState == RefreshIndicatorMode.armed;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: PinterestFourDotSpinner(
                    percentage: percentage,
                    isRefreshing: isActivelyRefreshing,
                  ),
                ),
              );
            },
          ),
          
          // The main Masonry Grid, converted to a Sliver
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childCount: photos.length,
              itemBuilder: (context, index) {
                return PinGridItem(photo: photos[index], iconColor: iconColor);
              },
            ),
          ),
        ],
      ),
      loading: () => const PinterestLoader(), // The 3-dot center loader for initial load
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildMasonryGrid(AsyncValue feedState, Color iconColor) {
    return feedState.when(
      data: (photos) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: photos.length,
          itemBuilder: (context, index) {
            // We use a dedicated Stateful Widget for each image to handle the complex gesture math
            return PinGridItem(photo: photos[index], iconColor: iconColor);
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

// ===========================================================================
// Stateful Pin Grid Item (Handles the Drag-and-Release Overlay Logic)
// ===========================================================================
class PinGridItem extends StatefulWidget {
  final PexelsPhoto photo;
  final Color iconColor;

  const PinGridItem({super.key, required this.photo, required this.iconColor});

  @override
  State<PinGridItem> createState() => _PinGridItemState();
}

class _PinGridItemState extends State<PinGridItem> {
  OverlayEntry? _overlayEntry;
  final ValueNotifier<Offset> _dragPosition = ValueNotifier(Offset.zero);
  Offset _initialPosition = Offset.zero;
  int? _lastHoveredIndex;

  // The exact relative positions of the circular icons from the user's thumb
  final List<RadialItem> _radialItems = [
    RadialItem(Icons.share_rounded, const Offset(-60, -80), 'Share'),
    RadialItem(Icons.manage_search_rounded, const Offset(40, -90), 'Search'),
    RadialItem(Icons.wechat_rounded, const Offset(90, -20), 'WhatsApp'),
    RadialItem(Icons.push_pin_rounded, const Offset(-70, 40), 'Pin'),
  ];

  // Logic to determine which icon the finger is currently dragging over
  int? _getHoveredIndex(Offset currentDrag) {
    for (int i = 0; i < _radialItems.length; i++) {
      final itemCenter = _initialPosition + _radialItems[i].offset;
      // If the thumb is within 40 pixels of an icon's center, consider it hovered
      if ((currentDrag - itemCenter).distance < 40) {
        return i;
      }
    }
    return null;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    HapticFeedback.heavyImpact(); // Strong vibration on initial hold
    _initialPosition = details.globalPosition;
    _dragPosition.value = _initialPosition;
    _lastHoveredIndex = null;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return RadialMenuOverlay(
          initialPosition: _initialPosition,
          dragPositionNotifier: _dragPosition,
          items: _radialItems,
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _dragPosition.value = details.globalPosition;
    
    // Provide a subtle haptic "tick" when the finger crosses into an icon's hover zone
    int? currentIndex = _getHoveredIndex(details.globalPosition);
    if (currentIndex != _lastHoveredIndex) {
      if (currentIndex != null) HapticFeedback.selectionClick();
      _lastHoveredIndex = currentIndex;
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    // Determine what the user was hovering over when they lifted their finger
    int? finalSelection = _getHoveredIndex(details.globalPosition);
    if (finalSelection != null) {
      // THE ACTION HAPPENS HERE! 
      final selectedAction = _radialItems[finalSelection].label;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$selectedAction Clicked!')));
    }

    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/pin', extra: {'photo': widget.photo, 'heroTag': 'home_pin_${widget.photo.id}'});
          },
          onLongPressStart: _onLongPressStart,
          onLongPressMoveUpdate: _onLongPressMoveUpdate,
          onLongPressEnd: _onLongPressEnd,
          onLongPressCancel: _removeOverlay, // Safety catch if gesture is interrupted
          
          child: Hero(
            tag: 'home_pin_${widget.photo.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.photo.imageUrl,
                memCacheWidth: 400,
                fit: BoxFit.cover,
                // 1. Smooth, theme-aware shimmer
                placeholder: (context, url) => buildSmoothShimmer(context),
                // 2. Extend the fade-in slightly and use a smooth curve to mask the layout jump
                fadeInDuration: const Duration(milliseconds: 400),
                fadeInCurve: Curves.easeOutCubic,
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showPinOptionsSheet(context, widget.photo);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, left: 8.0, right: 4.0),
            child: Icon(Icons.more_horiz_rounded, size: 20, color: widget.iconColor),
          ),
        ),
      ],
    );
  }

  // Breakout Bottom Sheet Logic
  void _showPinOptionsSheet(BuildContext context, PexelsPhoto photo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Wrap(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 120),
                  padding: const EdgeInsets.only(top: 150, bottom: 24),
                  decoration: BoxDecoration(color: sheetColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('This Pin is inspired by your recent activity', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 24),
                      _buildActionTile(Icons.push_pin_outlined, 'Save', textColor),
                      _buildActionTile(Icons.share_outlined, 'Share', textColor),
                      _buildActionTile(Icons.download_outlined, 'Download image', textColor),
                      _buildActionTile(Icons.favorite_border_rounded, 'See more like this', textColor),
                      _buildActionTile(Icons.visibility_off_outlined, 'See less like this', textColor),
                      _buildActionTile(Icons.block, 'Report Pin', textColor, subtitle: "This goes against Pinterest's community guidelines"),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)]),
                    child: ClipRRect(borderRadius: BorderRadius.circular(20), child: CachedNetworkImage(imageUrl: photo.imageUrl, width: 140, height: 230, fit: BoxFit.cover)),
                  ),
                ),
                Positioned(top: 136, left: 16, child: IconButton(icon: Icon(Icons.close_rounded, color: textColor, size: 30), onPressed: () => Navigator.pop(context))),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, {String? subtitle}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 19)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: color.withOpacity(0.8), fontSize: 14)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      visualDensity: VisualDensity.compact,
      onTap: () {},
    );
  }
}

// ===========================================================================
// The Radial Menu Overlay (Full Screen Blur & Absolute Positioning)
// ===========================================================================
class RadialItem {
  final IconData icon;
  final Offset offset;
  final String label;
  RadialItem(this.icon, this.offset, this.label);
}

class RadialMenuOverlay extends StatelessWidget {
  final Offset initialPosition;
  final ValueNotifier<Offset> dragPositionNotifier;
  final List<RadialItem> items;

  const RadialMenuOverlay({
    super.key,
    required this.initialPosition,
    required this.dragPositionNotifier,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder<Offset>(
        valueListenable: dragPositionNotifier,
        builder: (context, dragPos, child) {
          return BackdropFilter(
            // Blurs the entire background heavily
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  // 1. The Hollow Ring marking the original tap location
                  Positioned(
                    left: initialPosition.dx - 35, // Centered on tap X (70/2 = 35)
                    top: initialPosition.dy - 35,  // Centered on tap Y
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black54, width: 3),
                      ),
                    ),
                  ),

                  // 2. The Interactive Icons surrounding the tap
                  ...items.map((item) {
                    final itemCenter = initialPosition + item.offset;
                    final isHovered = (dragPos - itemCenter).distance < 40;

                    return Positioned(
                      left: itemCenter.dx - 28, // 56/2 = 28
                      top: itemCenter.dy - 28,
                      // The AnimatedScale makes the button "pop" smoothly when you drag over it
                      child: AnimatedScale(
                        scale: isHovered ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutBack,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333), // Exact Pinterest dark grey
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: isHovered ? 15 : 10,
                                spreadRadius: isHovered ? 2 : 1,
                              ),
                            ],
                          ),
                          child: Icon(item.icon, color: Colors.white, size: 28),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Theme-aware, perfectly rounded Shimmer placeholder
Widget buildSmoothShimmer(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  // Match the shimmer perfectly to the current theme
  final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
  final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
  final containerColor = isDark ? const Color(0xFF2B2B2B) : Colors.white;

  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: Container(
      // Removing the hardcoded 200 height and using a default generic height
      // combined with a smooth radius prevents the ugly box flash
      height: 250, 
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}