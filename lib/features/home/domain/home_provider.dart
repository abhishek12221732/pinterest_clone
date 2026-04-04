import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'pexels_model.dart';

// Provider for the Dio client so it can be injected
final dioProvider = Provider<DioClient>((ref) => DioClient());

// Modern Riverpod 2.x AsyncNotifier
class HomeFeedNotifier extends AsyncNotifier<List<PexelsPhoto>> {
  
  @override
  FutureOr<List<PexelsPhoto>> build() async {
    // build() automatically sets the state to AsyncValue.loading() 
    // while it waits for this function to finish.
    return _fetchCuratedPhotos();
  }

  Future<List<PexelsPhoto>> _fetchCuratedPhotos() async {
    final dioClient = ref.read(dioProvider); // Use ref.read inside notifiers
    
    // Pexels curated endpoint gets random high-quality images
    final response = await dioClient.dio.get('curated?per_page=30');
    
    final List<dynamic> photosJson = response.data['photos'];
    return photosJson.map((json) => PexelsPhoto.fromJson(json)).toList();
  }

  // A helper method if you want to implement "pull-to-refresh" later
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCuratedPhotos());
  }
}

// The modern provider that the UI will listen to
final homeFeedProvider = AsyncNotifierProvider<HomeFeedNotifier, List<PexelsPhoto>>(() {
  return HomeFeedNotifier();
});