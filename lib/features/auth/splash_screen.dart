import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const SplashScreen({super.key, required this.themeNotifier});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(themeNotifier: widget.themeNotifier),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/Animation - 1743866333824.json',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              tr('splash.title'),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
