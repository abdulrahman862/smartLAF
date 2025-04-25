import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:prototype1/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final themeNotifier = ValueNotifier(ThemeMode.light);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
          Locale('fr'),
          Locale('es'),
          Locale('de'),
          Locale('pt'),
          Locale('zh'),
          Locale('it'),
        ],
        path: 'assets/langs',
        fallbackLocale: const Locale('en'),
        child: MyApp(themeNotifier: themeNotifier),
      ),
    );

    await tester.pumpAndSettle();

    // ✅ Example test: Check for splash screen text
    expect(find.text('Smart Lost & Found'), findsOneWidget);
  });
}
