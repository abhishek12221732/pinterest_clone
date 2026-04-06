import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/domain/pexels_model.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/pin_detail_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart'; 

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/', 
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/pin',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>; 
        return PinDetailScreen(
          photo: data['photo'] as PexelsPhoto,
          heroTag: data['heroTag'] as String,
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/search', builder: (context, state) => const SearchScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/create', builder: (context, state) => const SizedBox.shrink())]),
        StatefulShellBranch(routes: [GoRoute(path: '/inbox', builder: (context, state) => const InboxScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())]),
      ],
    ),
  ],
);

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});
  
  final StatefulNavigationShell navigationShell;

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Start creating now', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCreateOption(context, Icons.push_pin_rounded, 'Pin'),
                    _buildCreateOption(context, Icons.dashboard_customize_rounded, 'Collage'),
                    _buildCreateOption(context, Icons.space_dashboard_rounded, 'Board'),
                  ],
                ),
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200], 
                    foregroundColor: Theme.of(context).colorScheme.secondary
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateOption(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        // 1. STRICT HEIGHT CONTROL: Forces the nav bar to be shorter (standard is 60-65)
        height: 54, 
        decoration: BoxDecoration(
          border: Border(
            // Optional: Adds that microscopic hair-line border at the top of the nav bar
            top: BorderSide(color: isDark ? Colors.grey[900]! : Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            type: BottomNavigationBarType.fixed,
            
            // 2. OBLITERATE GHOST PADDING: 
            showSelectedLabels: false, 
            showUnselectedLabels: false,
            selectedFontSize: 0.0,
            unselectedFontSize: 0.0,
            
            // Scaled the icons down just a hair so they fit the new tight height perfectly
            iconSize: 30, 
            
            selectedItemColor: textColor,
            unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[400],
            
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              if (index == 2) {
                _showCreateModal(context);
                return;
              }
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), 
                activeIcon: Icon(Icons.home_filled), 
                label: ''
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded), 
                activeIcon: Icon(Icons.search_rounded), 
                label: ''
              ),
              BottomNavigationBarItem(
                // The center Add is still slightly larger than the rest
                icon: Icon(Icons.add_rounded, size: 36), 
                label: ''
              ), 
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded), 
                activeIcon: Icon(Icons.chat_bubble_rounded), 
                label: ''
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded), 
                activeIcon: Icon(Icons.person_rounded), 
                label: ''
              ),
            ],
          ),
        ),
      ),
    );
  }
}