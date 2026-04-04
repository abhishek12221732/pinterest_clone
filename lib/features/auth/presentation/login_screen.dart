import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          // FIXED: This is the correct pre-built widget for Clerk in Flutter
          child: ClerkAuthentication(), 
        ),
      ),
    );
  }
}