import 'package:flutter/material.dart';
import 'package:sahaaya/l10n/app_localizations.dart';
import 'package:sahaaya/locale_controller.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AppBar(
      leading: const Icon(Icons.air, size: 25.0),
      title: Text(
        t.appTitle,
        style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          onSelected: (value) {
            switch (value) {
              case 'en':
                LocaleController.of(context).setLocale(const Locale('en'));
                break;
              case 'es':
                LocaleController.of(context).setLocale(const Locale('es'));
                break;
              case 'hi':
                LocaleController.of(context).setLocale(const Locale('hi'));
                break;
              case 'pa':
                LocaleController.of(context).setLocale(const Locale('pa'));
                break;
              case 'ta':
                LocaleController.of(context).setLocale(const Locale('ta'));
                break;
              case 'te':
                LocaleController.of(context).setLocale(const Locale('te'));
                break;
              case 'bn':
                LocaleController.of(context).setLocale(const Locale('bn'));
                break;
              case 'gu':
                LocaleController.of(context).setLocale(const Locale('gu'));
                break;
              case 'mr':
                LocaleController.of(context).setLocale(const Locale('mr'));
                break;
              case 'kn':
                LocaleController.of(context).setLocale(const Locale('kn'));
                break;
              case 'ml':
                LocaleController.of(context).setLocale(const Locale('ml'));
                break;
              default:
                LocaleController.of(context).setLocale(null);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'en', child: Text('English')),
            PopupMenuItem(value: 'es', child: Text('Español')),
            PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
            PopupMenuItem(value: 'pa', child: Text('ਪੰਜਾਬੀ')),
            PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
            PopupMenuItem(value: 'te', child: Text('తెలుగు')),
            PopupMenuItem(value: 'bn', child: Text('বাংলা')),
            PopupMenuItem(value: 'gu', child: Text('ગુજરાતી')),
            PopupMenuItem(value: 'mr', child: Text('मराठी')),
            PopupMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
            PopupMenuItem(value: 'ml', child: Text('മലയാളം')),
          ],
        ),
      ],
    );
  }
}
