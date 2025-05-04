import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // Map language codes to names
  final Map<String, String> supportedLocales = {
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'pt': 'Português',
    'zh': '中文 (Chinese)',
    'it': 'Italiano',
  };

  // Map language codes to actual image asset paths
  final Map<String, String> flagPaths = {
    'en': 'assets/flags/united-kingdom (1).png',
    'ar': 'assets/flags/saudi (1).png',
    'fr': 'assets/flags/france (1).png',
    'es': 'assets/flags/spain (1).png',
    'de': 'assets/flags/germany (1).png',
    'pt': 'assets/flags/portugal (1).png',
    'zh': 'assets/flags/china (1).png',
    'it': 'assets/flags/italy (1).png',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = context.locale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
        title: Text('settings.language'.tr(), style: theme.textTheme.titleLarge),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        itemCount: supportedLocales.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final code = supportedLocales.keys.elementAt(index);
          final name = supportedLocales[code]!;
          final flagAsset = flagPaths[code];
          final isSelected = currentLocale == code;

          return GestureDetector(
            onTap: () async {
              await context.setLocale(Locale(code));
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : const SizedBox(width: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (flagAsset != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        flagAsset,
                        width: 28,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 28, height: 20),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
