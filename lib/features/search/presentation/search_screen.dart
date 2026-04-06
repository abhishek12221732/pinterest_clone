import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../domain/search_provider.dart';
import '../../home/domain/home_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.secondary;
    // Pinterest uses a very dark grey for the search bar in dark mode, almost blending in
    final searchBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[200]; 

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. The Floating Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: searchBarColor,
                        borderRadius: BorderRadius.circular(25),
                        // Slight border to match the screenshot
                        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.transparent, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => ref.read(searchProvider.notifier).search(value),
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Search for ideas',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
                          prefixIcon: Icon(Icons.search_rounded, color: textColor),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSearching)
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(searchProvider.notifier).search('');
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              IconButton(
                                icon: Icon(Icons.camera_alt_outlined, color: textColor),
                                onPressed: () => HapticFeedback.lightImpact(),
                              ),
                            ],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  if (_isSearching)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          ref.read(searchProvider.notifier).search('');
                          FocusScope.of(context).unfocus();
                        },
                        child: Text('Cancel', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Dynamic Content Area
            Expanded(
              child: _isSearching 
                  ? _buildSearchResults(searchState, textColor) 
                  : _buildExploreState(textColor, isDark),
            ),
          ],
        ),
      ),
      // The floating search FAB visible in the bottom right of the screenshot
      floatingActionButton: !_isSearching ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: isDark ? const Color(0xFF333333) : Colors.white,
        foregroundColor: textColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.search_rounded, size: 28),
      ) : null,
    );
  }

  // ===========================================================================
  // IDLE STATE: The Exact Pinterest Explore Layout
  // ===========================================================================
  Widget _buildExploreState(Color textColor, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Full-Width PageView Carousel
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  itemCount: _mockIdeas.length,
                  itemBuilder: (context, index) {
                    final item = _mockIdeas[index];
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(item['image']!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                        ),
                      ),
                      alignment: Alignment.centerLeft, // Matches screenshot alignment
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        item['title']!,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                    );
                  },
                ),
                // Pagination Dots
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == 0 ? Colors.white : Colors.white54,
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // Featured Boards Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore featured boards', style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('Bring your inspiration to life', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Horizontally Scrolling Collage Cards
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _mockBoards.length,
              itemBuilder: (context, index) {
                return _buildCollageBoardCard(_mockBoards[index], textColor, isDark);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Ideas For You Section (Korean example from screenshot)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ideas for you', style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                // Text('Learn korean', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInitialGrid(textColor),
        ],
      ),
    );
  }

  // ===========================================================================
  // The Complex Collage Board Card (1 Big Image Left, 2 Small Stacked Right)
  // ===========================================================================
  Widget _buildCollageBoardCard(Map<String, dynamic> board, Color textColor, bool isDark) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Collage Frame
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Colors.grey[900] : Colors.grey[200],
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                // Big Left Image
                Expanded(
                  flex: 2,
                  child: CachedNetworkImage(imageUrl: board['mainImage'], fit: BoxFit.cover, height: double.infinity),
                ),
                const SizedBox(width: 2), // Small divider line
                // Stacked Right Images
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(child: CachedNetworkImage(imageUrl: board['subImage1'], fit: BoxFit.cover, width: double.infinity)),
                      const SizedBox(height: 2),
                      Expanded(child: CachedNetworkImage(imageUrl: board['subImage2'], fit: BoxFit.cover, width: double.infinity)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Metadata
          Text(board['title'], style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(board['author'], style: TextStyle(color: textColor, fontSize: 14)),
              const SizedBox(width: 4),
              if (board['verified'] == true) 
                const Icon(Icons.check_circle, color: Colors.red, size: 14),
              if (board['collaborators'] != null)
                Text(' + ${board['collaborators']}', style: TextStyle(color: textColor, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 2),
          Text('${board['pins']} Pins · ${board['time']}', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTIVE STATE: Search Results Grid
  // ===========================================================================
  Widget _buildSearchResults(AsyncValue searchState, Color iconColor) {
    return searchState.when(
      data: (photos) {
        if (photos.isEmpty) return const Center(child: Text('No results found.'));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(imageUrl: photo.imageUrl, memCacheWidth: 400, fit: BoxFit.cover),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildInitialGrid(Color iconColor) {
    final initialFeedState = ref.watch(homeFeedProvider); 
    return initialFeedState.when(
      data: (photos) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: MasonryGridView.count(
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: photos.length > 8 ? 8 : photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(imageUrl: photo.imageUrl, memCacheWidth: 400, fit: BoxFit.cover),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
      error: (err, stack) => const SizedBox(),
    );
  }

  // ===========================================================================
  // MOCK DATA TO MATCH SCREENSHOT
  // ===========================================================================
  final List<Map<String, String>> _mockIdeas = [
    {'title': 'Start a nature journal', 'image': 'https://images.pexels.com/photos/4096964/pexels-photo-4096964.jpeg?auto=compress&cs=tinysrgb&w=800'},
    {'title': 'Autumn aesthetics', 'image': 'https://images.pexels.com/photos/1563356/pexels-photo-1563356.jpeg?auto=compress&cs=tinysrgb&w=800'},
  ];

  final List<Map<String, dynamic>> _mockBoards = [
    {
      'title': 'Viral food photo ideas',
      'author': 'Art',
      'verified': true,
      'pins': '77',
      'time': '2w',
      'mainImage': 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400',
      'subImage1': 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=200',
      'subImage2': 'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg?auto=compress&cs=tinysrgb&w=200',
    },
    {
      'title': 'Home workout reset',
      'author': 'Pinterest Man',
      'verified': true,
      'collaborators': '1',
      'pins': '70',
      'time': '1w',
      'mainImage': 'https://images.pexels.com/photos/4164844/pexels-photo-4164844.jpeg?auto=compress&cs=tinysrgb&w=400',
      'subImage1': 'https://images.pexels.com/photos/4164845/pexels-photo-4164845.jpeg?auto=compress&cs=tinysrgb&w=200',
      'subImage2': 'https://images.pexels.com/photos/4164843/pexels-photo-4164843.jpeg?auto=compress&cs=tinysrgb&w=200',
    },
  ];
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