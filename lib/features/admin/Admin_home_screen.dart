import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminHomeScreen extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const AdminHomeScreen({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          tr('admin.title'), // Optional: add localization if needed
          style: TextStyle(color: theme.appBarTheme.foregroundColor ?? theme.primaryTextTheme.titleLarge?.color),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: Center(
        child: Text(
          tr('admin.welcome'), // Optional: add localized welcome message
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
