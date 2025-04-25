import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'features/home/screens/SearchResultsScreen.dart';
import 'features/home/screens/filter_by_search_screen.dart';
import 'features/home/screens/user_home_screen.dart';
import 'features/home/screens/admin_home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';

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
