import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

late final ValueNotifier<ThemeMode> themeNotifier;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  // 🌗 Load theme preference from storage
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier = ValueNotifier(isDark ? ThemeMode.dark : ThemeMode.light);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
        Locale('fr'), // French
        Locale('es'), // Spanish
        Locale('de'), // German
        Locale('pt'), // Portuguese
        Locale('zh'), // Chinese
        Locale('it'), // Italian
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      child: MyApp(themeNotifier: themeNotifier), // 🔗 Uses saved theme
    ),
  );
}
