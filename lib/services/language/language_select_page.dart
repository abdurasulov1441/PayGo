import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/style/app_colors.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  Locale? selectedLocale;

  final List<Map<String, dynamic>> languages = [
    {'locale': const Locale('uz'), 'name': 'O‘zbekcha', 'flag': '🇺🇿'},
    {'locale': const Locale('ru'), 'name': 'Русский', 'flag': '🇷🇺'},
    {'locale': const Locale('uk'), 'name': 'Ўзбекча', 'flag': '🇺🇿'},
  ];

  void _updateLocale(Locale locale) {
    setState(() {
      selectedLocale = locale;
      context.setLocale(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LottieBuilder.asset('assets/lottie/language.json'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'chosen_language',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ).tr(),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'language'.tr(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  return GestureDetector(
                    onTap: () {
                      _updateLocale(lang['locale']);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: selectedLocale == lang['locale']
                            ? AppColors.grade2
                            : Colors.white,
                        border: Border.all(
                          color: selectedLocale == lang['locale']
                              ? AppColors.grade1
                              : AppColors.grade1,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Text(
                            lang['flag'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            lang['name'],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedLocale != null
                  ? () {
                      GoRouter.of(context).push(Routes.loginScreen);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedLocale != null ? AppColors.grade2 : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'continue',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ).tr(),
            ),
          ],
        ),
      ),
    );
  }
}
