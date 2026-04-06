import 'dart:math'; // Required for random numbers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'pexels_model.dart';

final dioProvider = Provider<DioClient>((ref) => DioClient());

final homeFeedProvider = FutureProvider.family<List<PexelsPhoto>, String>((ref, category) async {
  final dioClient = ref.read(dioProvider); 
  final query = category == 'All' ? 'aesthetic pinterest' : category;
  
  // THE FIX: Generate a random page number between 1 and 10
  // so every refresh gets a brand new set of images.
  final randomPage = Random().nextInt(10) + 1;
  
  // Pass the random page to the API
  final response = await dioClient.dio.get('search?query=$query&per_page=30&page=$randomPage');
  
  final List<dynamic> photosJson = response.data['photos'];
  return photosJson.map((json) => PexelsPhoto.fromJson(json)).toList();
});