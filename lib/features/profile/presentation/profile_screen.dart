import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('My Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('@developer • 0 followers', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], 
                    foregroundColor: Colors.black, 
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text('Share profile'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], 
                    foregroundColor: Colors.black, 
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text('Edit profile'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Simulated logout flow for the assignment
            TextButton(
              onPressed: () {
                 context.go('/login');
              },
              child: const Text('Sign Out', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}