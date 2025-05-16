import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const AdminHomeScreen({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.videocam, size: 100, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Live Camera Stream (placeholder)',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
