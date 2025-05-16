import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prototype1/features/User/SearchResultsScreen.dart';
import 'package:prototype1/features/User/filter_by_search_screen.dart';
import 'package:prototype1/features/User/User_home_screen.dart';
import 'package:prototype1/features/admin/Admin_home_screen.dart';
import 'package:prototype1/features/auth/login_screen.dart';
import 'package:prototype1/features/auth/splash_screen.dart';

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'Smart Lost & Found',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: SplashScreen(themeNotifier: themeNotifier),
          routes: {
            '/login': (context) => LoginScreen(themeNotifier: themeNotifier),
            '/userHome': (context) => HomeScreen(themeNotifier: themeNotifier),
            '/adminHome': (context) => AdminHomeScreen(themeNotifier: themeNotifier),
            '/filter': (context) => FilterBySearchScreen(themeNotifier: themeNotifier),
            '/results': (context) => const SearchResultsScreen(locations: []),
          },
        );
      },
    );
  }
}
