import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../domain/search_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                // Triggers our debounce method on every keystroke
                onChanged: (value) => ref.read(searchProvider.notifier).search(value),
                decoration: InputDecoration(
                  hintText: 'Search for ideas',
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Pinterest pill shape
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: searchState.when(
                data: (photos) {
                  if (photos.isEmpty) {
                    return const Center(
                      child: Text('Search for inspiration', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            // Notice the 'search_pin_' prefix! No collisions with the home feed.
                            context.push('/pin', extra: {
                              'photo': photo,
                              'heroTag': 'search_pin_${photo.id}'
                            });
                          },
                          child: Hero(
                            tag: 'search_pin_${photo.id}', 
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: photo.imageUrl,
                                memCacheWidth: 400,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(height: 200, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}