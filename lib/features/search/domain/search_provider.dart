import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/domain/pexels_model.dart';
import '../../home/domain/home_provider.dart'; // To reuse the dioProvider

class SearchNotifier extends AsyncNotifier<List<PexelsPhoto>> {
  Timer? _debounceTimer;

  @override
  FutureOr<List<PexelsPhoto>> build() {
    return []; // Start with an empty list before searching
  }

  void search(String query) {
    // Cancel the previous timer if the user is still typing
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    // Wait 500ms after typing stops before calling the API
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncValue.loading();
      
      state = await AsyncValue.guard(() async {
        final dioClient = ref.read(dioProvider);
        final response = await dioClient.dio.get('search?query=$query&per_page=30');
        
        final List<dynamic> photosJson = response.data['photos'];
        return photosJson.map((json) => PexelsPhoto.fromJson(json)).toList();
      });
    });
  }
}

final searchProvider = AsyncNotifierProvider<SearchNotifier, List<PexelsPhoto>>(() {
  return SearchNotifier();
});