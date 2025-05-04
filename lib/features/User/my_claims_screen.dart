import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prototype1/features/User/settings_screen.dart';
import 'package:prototype1/features/User/User_home_screen.dart';

class MyClaimsScreen extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MyClaimsScreen({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'nav.claims'.tr(),
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'claims.no_items'.tr(),
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(themeNotifier: themeNotifier)),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen(themeNotifier: themeNotifier)),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'nav.home'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.check_circle), label: 'nav.claims'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'nav.settings'.tr()),
        ],
      ),
    );
  }
}
