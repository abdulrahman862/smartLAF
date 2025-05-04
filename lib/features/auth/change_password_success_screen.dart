import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prototype1/features/User/account_info_screen.dart';

class ChangePasswordSuccessScreen extends StatefulWidget {
  const ChangePasswordSuccessScreen({super.key});

  @override
  State<ChangePasswordSuccessScreen> createState() => _ChangePasswordSuccessScreenState();
}

class _ChangePasswordSuccessScreenState extends State<ChangePasswordSuccessScreen> {
  @override
  void initState() {
    super.initState();

    // ⏳ Auto-navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/Animation - 1743893659152.json',
              width: 200,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              'change_password.success_message'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
