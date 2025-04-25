import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prototype1/features/home/screens/my_claims_screen.dart';
import 'package:prototype1/features/home/screens/user_home_screen.dart';
import 'package:prototype1/features/home/screens/filter_by_search_screen.dart';
import 'package:prototype1/features/home/screens/account_info_screen.dart';
import 'package:prototype1/features/home/screens/language_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const SettingsScreen({super.key, required this.themeNotifier});

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('settings.account'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('settings.view_account'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
            ),
          ),
          const Divider(height: 32),
          Text('settings.preferences'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: Text('settings.notifications'.tr()),
            secondary: const Icon(Icons.notifications_active),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('settings.language'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              return SwitchListTile(
                value: themeMode == ThemeMode.dark,
                onChanged: (isDark) async {
                  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                  await _saveThemePreference(isDark);
                },
                title: Text('settings.theme'.tr()),
                secondary: const Icon(Icons.color_lens),
              );
            },
          ),
          const Divider(height: 32),
          Text('settings.support'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text('settings.faq'.tr()),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text('settings.privacy'.tr()),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('settings.logout'.tr()),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(themeNotifier: themeNotifier)));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FilterBySearchScreen(themeNotifier: themeNotifier)));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyClaimsScreen(themeNotifier: themeNotifier)));
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
}
