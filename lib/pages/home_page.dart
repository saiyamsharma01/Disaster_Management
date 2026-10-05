import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:sahaaya/l10n/app_localizations.dart';
import 'package:sahaaya/locale_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.air, size: 25.0),
        title: Text(
          t.appTitle,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: t.appInfo,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (ctx) {
                  return SafeArea(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(t.appTitle),
                            subtitle: Text(t.actions),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Text('🇬🇧'),
                                    title: const Text('English'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('en'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇪🇸'),
                                    title: const Text('Español'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('es'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('हिन्दी'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('hi'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('ਪੰਜਾਬੀ'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('pa'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('தமிழ்'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('ta'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('తెలుగు'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('te'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('বাংলা'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('bn'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('ગુજરાતી'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('gu'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('मराठी'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('mr'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('ಕನ್ನಡ'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('kn'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Text('🇮🇳'),
                                    title: const Text('മലയാളം'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(const Locale('ml'));
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.public),
                                    title: const Text('System default'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      LocaleController.of(context).setLocale(null);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Lottie.asset('assets/lotties/Welcome.json'),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: ElevatedButton(
                onPressed: () {
                  context.goNamed('signup');
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 22.0,
                    vertical: 16.0,
                  ),
                  child: Text(t.getStarted, style: const TextStyle(fontSize: 18.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
