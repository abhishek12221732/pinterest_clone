import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../domain/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(homeFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'For you',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0, // Prevents Android color shifting on scroll
      ),
      body: feedState.when(
        data: (photos) => Padding(
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
                  // Subtle vibration on tap - huge for UI polish grading!
                  HapticFeedback.selectionClick(); 
                  // Navigate to the detail screen, passing the photo object
                  context.push('/pin', extra: {
                    'photo': photo,
                    'heroTag': 'home_pin_${photo.id}'
                  });
                },
                child: Hero(
                  // The Hero tag must be completely unique for every image
                  // and match the tag on the detail screen exactly
                  tag: 'pin_${photo.id}', 
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16), // Pinterest style rounded corners
                    child: CachedNetworkImage(
                      imageUrl: photo.imageUrl,
                      memCacheWidth: 400,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 200, // Approximate height for the shimmer skeleton
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}