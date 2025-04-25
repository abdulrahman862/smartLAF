import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prototype1/features/home/screens/filter_by_search_screen.dart';
import 'package:prototype1/features/home/screens/my_claims_screen.dart';
import 'package:prototype1/features/home/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const HomeScreen({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    final sampleItems = List.generate(20, (index) {
      return {
        'itemName': 'Item ${index + 1}',
        'location': 'Main Lobby',
        'date': '2025-04-08',
        'status': ['Detected', 'Retrieved', 'Stored', 'Ready for Pickup'][index % 4],
        'imageUrl': null,
      };
    }).where((item) => item['status'] == 'Ready for Pickup').toList();

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final inputColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'home.title'.tr(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: theme.iconTheme.color),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // 🔍 Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: inputColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'home.search_hint'.tr(),
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: theme.iconTheme.color),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'home.recently_found'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'home.see_all'.tr(),
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: sampleItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final item = sampleItems[index];
                  return _buildItemCard(item, context);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => FilterBySearchScreen(themeNotifier: themeNotifier)),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MyClaimsScreen(themeNotifier: themeNotifier)),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen(themeNotifier: themeNotifier)),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'nav.home'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: 'nav.browse'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.check_circle), label: 'nav.claims'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'nav.settings'.tr()),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(item['itemName'], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          Text(item['location'], style: TextStyle(color: textColor.withOpacity(0.6))),
          const Spacer(),
        ],
      ),
    );
  }
}
