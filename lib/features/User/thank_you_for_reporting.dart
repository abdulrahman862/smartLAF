import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:prototype1/features/User/User_home_screen.dart';

class ThankYouForReportingScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const ThankYouForReportingScreen({super.key, required this.themeNotifier});

  @override
  State<ThankYouForReportingScreen> createState() => _ThankYouForReportingScreenState();
}

class _ThankYouForReportingScreenState extends State<ThankYouForReportingScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate back to Home after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(themeNotifier: widget.themeNotifier)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/Animation - 1743893659152.json',
              width: 180,
              height: 180,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              'report.thank_you'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
