import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.secondary;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: false, 
        title: Text(
          'Inbox',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_square, color: textColor, size: 28),
            onPressed: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // ===============================================================
              // 1. MESSAGES SECTION
              // ===============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Messages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Row(
                      children: [
                        Text('See all', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                        Icon(Icons.chevron_right_rounded, color: textColor, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Simulated User Message
              _buildMessageTile(
                context: context,
                leading: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=100',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: 'Elena Rodriguez',
                subtitle: 'Sent a Pin',
                trailingText: '1d',
                textColor: textColor,
                subtitleColor: subtitleColor!,
              ),
              const SizedBox(height: 16),
              // Default "Find People" Action
              _buildMessageTile(
                context: context,
                leading: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[300], shape: BoxShape.circle),
                  child: Icon(Icons.person_add_alt_1_rounded, color: textColor, size: 26),
                ),
                title: 'Find people to message',
                subtitle: 'Connect to start chatting',
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),

              const SizedBox(height: 32),

              // ===============================================================
              // 2. UPDATES SECTION
              // ===============================================================
              Text('Updates', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              
              // Rich Image Updates (Updated to 2026)
              _buildUpdateTile(
                context: context,
                imageUrl: 'https://images.pexels.com/photos/1762851/pexels-photo-1762851.jpeg?auto=compress&cs=tinysrgb&w=200',
                title: 'These ideas are so you · Apr 5, 2026',
                textColor: textColor,
              ),
              _buildUpdateTile(
                context: context,
                imageUrl: 'https://images.pexels.com/photos/1648377/pexels-photo-1648377.jpeg?auto=compress&cs=tinysrgb&w=200',
                title: 'Anime Drawing for you · Apr 4, 2026',
                textColor: textColor,
              ),
              _buildUpdateTile(
                context: context,
                imageUrl: 'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg?auto=compress&cs=tinysrgb&w=200',
                title: 'Silly Jokes for you · Apr 2, 2026',
                textColor: textColor,
              ),
              _buildUpdateTile(
                context: context,
                imageUrl: 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=200',
                title: 'Funny Quotes for you · Mar 28, 2026',
                textColor: textColor,
              ),
              _buildUpdateTile(
                context: context,
                imageUrl: 'https://images.pexels.com/photos/3153204/pexels-photo-3153204.jpeg?auto=compress&cs=tinysrgb&w=200',
                title: 'Minimalist UI design · Mar 25, 2026',
                textColor: textColor,
              ),
              _buildUpdateTile(
                context: context,
                imageUrl: 'https://images.pexels.com/photos/2079438/pexels-photo-2079438.jpeg?auto=compress&cs=tinysrgb&w=200',
                title: 'Cozy coffee setups · Mar 20, 2026',
                textColor: textColor,
              ),
              _buildUpdateTile(
                context: context,
                imageUrl: 'https://images.pexels.com/photos/1741205/pexels-photo-1741205.jpeg?auto=compress&cs=tinysrgb&w=400',
                title: 'Dark academia aesthetics · Mar 15, 2026',
                textColor: textColor,
              ),
              
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTile({
    required BuildContext context,
    required Widget leading,
    required String title,
    required String subtitle,
    String? trailingText,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return InkWell(
      onTap: () => HapticFeedback.selectionClick(),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 15, color: subtitleColor)),
                ],
              ),
            ),
            if (trailingText != null)
              Text(trailingText, style: TextStyle(fontSize: 14, color: subtitleColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateTile({
    required BuildContext context,
    required String imageUrl,
    required String title,
    required Color textColor,
  }) {
    return InkWell(
      onTap: () => HapticFeedback.selectionClick(),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title, 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor, height: 1.3),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.more_horiz_rounded, color: textColor),
              onPressed: () {
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
      ),
    );
  }
}