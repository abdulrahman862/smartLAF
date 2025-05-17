import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prototype1/features/User/my_claims_screen.dart';
import 'package:prototype1/features/User/User_home_screen.dart';
import 'package:prototype1/features/User/account_info_screen.dart';
import 'package:prototype1/features/User/language_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const SettingsScreen({super.key, required this.themeNotifier});

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToScreenWithReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final accentColor = isDarkMode ? Colors.blueAccent : const Color(0xFF4A80F0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'settings.manage_your_account'.tr(),
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                children: [
                  Text(
                    'settings.account'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context,
                    Icons.person,
                    'settings.view_account'.tr(),
                    'settings.view_account_desc'.tr(),
                    accentColor,
                        () => _navigateToScreen(context, const AccountInfoScreen()),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'settings.preferences'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchCard(
                    context,
                    Icons.notifications_active,
                    'settings.notifications'.tr(),
                    'settings.notifications_desc'.tr(),
                    true,
                    accentColor,
                        (val) {},
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context,
                    Icons.language,
                    'settings.language'.tr(),
                    'settings.language_desc'.tr(),
                    accentColor,
                        () => _navigateToScreen(context, const LanguageSelectionScreen()),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, themeMode, _) {
                      return _buildSwitchCard(
                        context,
                        Icons.color_lens,
                        'settings.theme'.tr(),
                        'settings.theme_desc'.tr(),
                        themeMode == ThemeMode.dark,
                        accentColor,
                            (isDark) async {
                          themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                          await _saveThemePreference(isDark);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'settings.support'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context,
                    Icons.help_outline,
                    'settings.faq'.tr(),
                    'settings.faq_desc'.tr(),
                    accentColor,
                        () {},
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context,
                    Icons.privacy_tip,
                    'settings.privacy'.tr(),
                    'settings.privacy_desc'.tr(),
                    accentColor,
                        () {},
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    context,
                    Icons.logout,
                    'settings.logout'.tr(),
                    'settings.logout_desc'.tr(),
                    Colors.redAccent,
                        () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/login',
                        result: PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => Scaffold(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, Icons.home_rounded, 'nav.home'.tr(), accentColor, () {
                  _navigateToScreenWithReplacement(
                    context,
                    HomeScreen(themeNotifier: themeNotifier),
                  );
                }),
                _buildNavItem(context, 1, Icons.check_circle_outline, 'nav.claims'.tr(), accentColor, () {
                  _navigateToScreenWithReplacement(
                    context,
                    MyClaimsScreen(themeNotifier: themeNotifier),
                  );
                }),
                _buildNavItem(context, 2, Icons.settings_outlined, 'nav.settings'.tr(), accentColor, null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, IconData icon, String title, String description, Color iconColor, VoidCallback? onTap) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: textColor?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard(BuildContext context, IconData icon, String title, String description, bool value, Color iconColor, Function(bool) onChanged) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: iconColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, Color accentColor, VoidCallback? onTap) {
    final isSelected = index == 2;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? accentColor : textColor?.withOpacity(0.5),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? accentColor : textColor?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}