import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamically grab text colors from your design system
    final textColor = Theme.of(context).colorScheme.secondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[200]; 
    final buttonColor = isDark ? const Color(0xFF2B2B2B) : Colors.grey[200];

    // Wrap in DefaultTabController to manage the tabs
    return DefaultTabController(
      length: 3, // Pins, Boards, Collages
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // Using a persistent top-to-bottom Column structure to replicate the specific screenshot.
        // No large header to scroll away, everything from avatar down to group row is persistent.
        body: SafeArea(
          child: Column(
            children: [
              // ===============================================================
              // 1. Persistent Header Section ( Avatar, Tabs, SearchBar, Add, Group )
              // This whole section is anchored to the top and remains visible.
              // ===============================================================
              Container(
                color: Theme.of(context).scaffoldBackgroundColor, // Ensure the background is solid
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Row 1: Profile Icon AND TabBar on the same line ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // Large circular avatar on the far left (Brown 'A' placeholder)
                          Container(
                            width: 60, height: 60,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: const BoxDecoration(color: Color(0xFFC06619), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ),
                          // Expanded TabBar that shares the row space
                          Expanded(
                            child: TabBar(
                              dividerColor: Colors.transparent, // Removes the standard bottom line
                              indicatorColor: textColor, // The stark black indicator from screenshot
                              indicatorSize: TabBarIndicatorSize.label,
                              labelColor: textColor,
                              unselectedLabelColor: Colors.grey[500],
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                              tabs: const [
                                Tab(text: 'Pins'),
                                Tab(text: 'Boards'),
                                Tab(text: 'Collages'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // --- Row 2: SearchBar and Add Icon (on the same line) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // Pill-shaped search bar for the profile section
                          Expanded(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: searchBarColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded, color: Colors.grey[500]),
                                  const SizedBox(width: 8),
                                  Text('Search your Pins', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // The 'Add' icon from screenshot
                          IconButton(
                            icon: Icon(Icons.add_rounded, color: textColor, size: 36),
                            onPressed: () => HapticFeedback.lightImpact(),
                          )
                        ],
                      ),
                    ),

                    // --- Row 3: Sort/Filter Icon and Group Button ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          IconButton(icon: Icon(Icons.swap_vert_rounded, color: textColor), onPressed: () {}),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () {},
                            child: const Text('Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ===============================================================
              // 2. Expanded Content Area: The standard TabBarView
              // ===============================================================
              Expanded(
                child: TabBarView(
                  // Now that the main structure is correct, we can use clean widgets for each tab
                  children: [
                    _buildPinsTab(textColor),
                    _buildBoardsTab(textColor, isDark),
                    _buildCollagesTab(textColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  //HELPER WIDGETS FOR EACH TAB'S CONTENT
  // We have dramatically increased the mock data lists to make it look "real."
  // ===========================================================================

  // Tab 1: Pins (Carousel of suggestions + Masonry grid of saved pins)
  Widget _buildPinsTab(Color textColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Native feel
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Board suggestions', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          // Horizontal carousel
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _mockBoardSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _mockBoardSuggestions[index];
                return Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(suggestion['image']!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    suggestion['title']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Masonry Grid: "Your saved Pins"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Your saved Pins', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Parent view handles scrolling
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: _mockSavedPins.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: _mockSavedPins[index],
                    fit: BoxFit.cover,
                    memCacheWidth: 400, // Performance optimization
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: Boards (Realistic 2-column grid of board collage cards)
  Widget _buildBoardsTab(Color textColor, bool isDark) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8, // Controls the card height/width ratio
      ),
      itemCount: _mockBoards.length,
      itemBuilder: (context, index) {
        return _buildBoardCard(_mockBoards[index], textColor, isDark);
      },
    );
  }

  // Complex Board Card Widget (1 Big Image Left, 2 Small Stacked Right)
  Widget _buildBoardCard(Map<String, dynamic> board, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Collage Frame
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Colors.grey[900] : Colors.grey[200],
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                // Big Left Image
                Expanded(flex: 2, child: CachedNetworkImage(imageUrl: board['mainImage'], fit: BoxFit.cover, height: double.infinity)),
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
        ),
        const SizedBox(height: 8),
        // Metadata
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(board['title'], style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${board['pins']} Pins · ${board['time']}', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  // Tab 3: Collages (Realistic Grid of Placeholder Collages)
  Widget _buildCollagesTab(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
      child: MasonryGridView.count(
        physics: const BouncingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _mockSavedPins.length, // Reusing diverse pin data for collage placeholders
        itemBuilder: (context, index) {
          // Wrap it to distinguish them from single pins
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // More roundedcorners for collages
                child: CachedNetworkImage(
                  imageUrl: _mockSavedPins[index],
                  memCacheWidth: 400,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text('Collage #${index + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// RICH REALISTIC MOCK DATA (Using diverse Pexels derived images)
// =============================================================================
final List<Map<String, String>> _mockBoardSuggestions = [
  {'title': 'Autumn aesthetics', 'image': 'https://images.pexels.com/photos/1563356/pexels-photo-1563356.jpeg?auto=compress&cs=tinysrgb&w=400'},
  {'title': 'Cozy coffee setups', 'image': 'https://images.pexels.com/photos/2079438/pexels-photo-2079438.jpeg?auto=compress&cs=tinysrgb&w=400'},
  {'title': 'Techsetup inspo', 'image': 'https://images.pexels.com/photos/777001/pexels-photo-777001.jpeg?auto=compress&cs=tinysrgb&w=400'},
  {'title': 'Silly cat jokes', 'image': 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=400'},
];

final List<String> _mockSavedPins = [
  'https://images.pexels.com/photos/3153204/pexels-photo-3153204.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/2079438/pexels-photo-2079438.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/1926769/pexels-photo-1926769.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/4096964/pexels-photo-4096964.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/1563356/pexels-photo-1563356.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/3278215/pexels-photo-3278215.jpeg?auto=compress&cs=tinysrgb&w=400',
];

final List<Map<String, dynamic>> _mockBoards = [
  {
    'title': 'Viral food photo ideas',
    'pins': '77', 'time': '2w',
    'mainImage': 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400',
    'subImage1': 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=200',
    'subImage2': 'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg?auto=compress&cs=tinysrgb&w=200',
  },
  {
    'title': 'Home workout reset',
    'pins': '70', 'time': '1w',
    'mainImage': 'https://images.pexels.com/photos/4164844/pexels-photo-4164844.jpeg?auto=compress&cs=tinysrgb&w=400',
    'subImage1': 'https://images.pexels.com/photos/4164845/pexels-photo-4164845.jpeg?auto=compress&cs=tinysrgb&w=200',
    'subImage2': 'https://images.pexels.com/photos/4164843/pexels-photo-4164843.jpeg?auto=compress&cs=tinysrgb&w=200',
  },
  {
    'title': 'Dark Academia Aesthetics',
    'pins': '156', 'time': '9mo',
    'mainImage': 'https://images.pexels.com/photos/1741205/pexels-photo-1741205.jpeg?auto=compress&cs=tinysrgb&w=400',
    'subImage1': 'https://images.pexels.com/photos/1762851/pexels-photo-1762851.jpeg?auto=compress&cs=tinysrgb&w=200',
    'subImage2': 'https://images.pexels.com/photos/1926769/pexels-photo-1926769.jpeg?auto=compress&cs=tinysrgb&w=200',
  },
  {
    'title': 'Living Room Decor',
    'pins': '124', 'time': '8mo',
    'mainImage': 'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=400',
    'subImage1': 'https://images.pexels.com/photos/2079438/pexels-photo-2079438.jpeg?auto=compress&cs=tinysrgb&w=200',
    'subImage2': 'https://images.pexels.com/photos/716107/pexels-photo-716107.jpeg?auto=compress&cs=tinysrgb&w=200',
  },
];