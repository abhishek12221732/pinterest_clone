import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'pexels_model.dart';

// Provider for the Dio client
final dioProvider = Provider<DioClient>((ref) => DioClient());

// The upgraded family provider that handles tabs and pull-to-refresh
final homeFeedProvider = FutureProvider.family<List<PexelsPhoto>, String>((ref, category) async {
  
  // 1. Get your existing Dio client
  final dioClient = ref.read(dioProvider); 
  
  // 2. Map the category to a good search term
  final query = category == 'All' ? 'aesthetic pinterest' : category;
  
  // 3. Hit the SEARCH endpoint (instead of curated) so we get category-specific images
  final response = await dioClient.dio.get('search?query=$query&per_page=30');
  
  // 4. Parse the JSON and return the list of photos
  final List<dynamic> photosJson = response.data['photos'];
  return photosJson.map((json) => PexelsPhoto.fromJson(json)).toList();
});