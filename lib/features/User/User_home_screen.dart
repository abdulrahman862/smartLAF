import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:prototype1/features/User/filter_by_search_screen.dart';
import 'package:prototype1/features/User/my_claims_screen.dart';
import 'package:prototype1/features/User/settings_screen.dart';
import 'package:prototype1/features/User/report_lost_item_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'home.title'.tr(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FilterBySearchScreen(themeNotifier: widget.themeNotifier),
              ),
            );
          } else if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ReportLostItemScreen(themeNotifier: widget.themeNotifier),
              ),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/lottie/Animation - 1746199354735.json',
                          controller: _controller,
                          onLoaded: (composition) {
                            _controller
                              ..duration = composition.duration
                              ..repeat();
                          },
                          width: 80,
                          height: 80,
                          errorBuilder: (_, __, ___) => const Icon(Icons.arrow_back, size: 40),
                        ),
                        const SizedBox(height: 8),
                        Text('home.swipe_report'.tr(), style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/lottie/arrow right.json',
                          controller: _controller,
                          onLoaded: (composition) {
                            _controller
                              ..duration = composition.duration
                              ..repeat();
                          },
                          width: 80,
                          height: 80,
                          errorBuilder: (_, __, ___) => const Icon(Icons.arrow_forward, size: 40),
                        ),
                        const SizedBox(height: 8),
                        Text('home.swipe_find'.tr(), style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MyClaimsScreen(themeNotifier: widget.themeNotifier)),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen(themeNotifier: widget.themeNotifier)),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'nav.home'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.check_circle), label: 'nav.claims'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'nav.settings'.tr()),
        ],
      ),
    );
  }
}
