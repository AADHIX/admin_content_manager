import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/content_item.dart';
import '../services/auth_service.dart';
import '../services/content_service.dart';
import '../screens/login_screens.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _authService = AuthService();
  final _contentService = ContentService();

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4), // was 0xFF0F1117
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // was 0xFF1A1D2E
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.explore_outlined,
              color: Color(0xFFFF6B2C), // was 0xFF3ECFCF
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Items',
              style: TextStyle(
                color: Color(0xFF1A0A00), // was Colors.white
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout,
                color: Color(0xFF000000), size: 18), // was Colors.white70
            label: const Text(
              'Logout',
              style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 16,
                  fontWeight: FontWeight.w600), // was Colors.white70
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<ContentItem>>(
        stream: _contentService.getContentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Color(0xFFFF6B2C)), // was 0xFF3ECFCF
                  SizedBox(height: 16),
                  Text(
                    'Loading content...',
                    style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 14), // was Colors.white54
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_outlined,
                      color: Color(0xFFE53935), // was Colors.redAccent
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load content',
                      style: TextStyle(
                        color: Color(0xFF1A0A00), // was Colors.white
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF000000), // was Colors.white54
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B2C), // was white5%
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.article_outlined,
                      size: 40,
                      color: Color(0xFFFF6B2C), // was white25%
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No content available yet',
                    style: TextStyle(
                      color: Color(0xFF000000), // was white50%
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back soon!',
                    style: TextStyle(
                      color: Color(0xFF000000), // was white30%
                      fontSize: 16, fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Read-only scrollable card list ──────────────────
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildContentCard(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildContentCard(ContentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // was 0xFF1A1D2E
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF000000)), // was white6%
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFFF6B2C), // was black30%
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ─────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFF0E8), // was white5%→white2%
                      Color(0xFFFFF8F4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B2C), // was 0xFF3ECFCF
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 220,
                color: const Color(0xFFFFF0E8), // was white4%
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 44,
                        color: Color(0xFF000000), // was white20%
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Image not available',
                        style: TextStyle(
                          color: Color(0xFF000000), // was white30%
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Text Content ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  // item.title rendered below — keeping widget structure identical
                  '', // placeholder; real usage below
                  style: TextStyle(),
                ),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF1A0A00), // was Colors.white
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 2,
                  width: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF9A5C),
                        Color(0xFFFF6B2C)
                      ], // was teal→purple
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color(0xFF000000), // was white60%
                    fontSize: 14,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
