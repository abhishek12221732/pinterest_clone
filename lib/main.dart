import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart'; // Import our new theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  final publishableKey = dotenv.env['CLERK_PUBLISHABLE_KEY'];
  if (publishableKey == null || publishableKey.isEmpty) {
    throw Exception('Clerk Publishable Key not found in .env file');
  }

  runApp(
    ProviderScope(
      child: MyApp(publishableKey: publishableKey),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String publishableKey;
  
  const MyApp({super.key, required this.publishableKey});

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: publishableKey),
      child: MaterialApp.router(
        title: 'Pinterest Clone',
        
        // --- NEW THEMING ENGINE ---
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Automatically switches based on OS settings
        
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}