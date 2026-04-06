import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.pexels.com/v1/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Authorization': dotenv.env['PEXELS_API_KEY'] ?? ''},
      ),
    );

    // Interceptor for logging and error handling
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // You can log requests here if needed
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Global error handling can go here
          return handler.next(e);
        },
      ),
    );
  }
}
