import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sahaaya/services/auth_service.dart';
import 'package:sahaaya/locale_controller.dart';
import 'package:sahaaya/l10n/app_localizations.dart';

class DashboardPageNeedy extends StatelessWidget {
  const DashboardPageNeedy({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the crossAxisCount based on screen width
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      // --- UI Enhancement: AppBar and Greeting remain as last update ---
      appBar: AppBar(
        leadingWidth: 230,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/sahaaya_logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.dashboard,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Language',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (ctx) {
                  final t = AppLocalizations.of(context)!;
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                while (context.canPop()) {
                  context.pop();
                }
                context.go('/login');
              }
            },
            tooltip: AppLocalizations.of(context)!.signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 20, top: 8),
              child: Text(
                AppLocalizations.of(context)!.assistQuestion,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // GridView of main actions
            Expanded(
              child: GridView.count(
                crossAxisCount: isWideScreen ? 3 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildDashboardCard(
                    context,
                    title: AppLocalizations.of(context)!.ivrDemo,
                    icon: LucideIcons.alertTriangle,
                    color: Colors.amber,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        builder: (ctx) {
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.quickViewIVROutcomes, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          context.goNamed('ivr_outcome', pathParameters: {'choice': '1'});
                                        },
                                        label: Text(AppLocalizations.of(context)!.emergencies1),
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.home, color: Colors.white),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          context.goNamed('ivr_outcome', pathParameters: {'choice': '2'});
                                        },
                                        label: Text(AppLocalizations.of(context)!.foodShelter2),
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.group, color: Colors.white),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          context.goNamed('ivr_outcome', pathParameters: {'choice': '3'});
                                        },
                                        label: Text(AppLocalizations.of(context)!.volunteers3),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(AppLocalizations.of(context)!.actions, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  ListTile(
                                    leading: const Icon(Icons.dialpad),
                                    title: Text(AppLocalizations.of(context)!.openIVRKeypad),
                                    subtitle: Text(AppLocalizations.of(context)!.recordFreshResponse),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      context.goNamed('ivr_demo');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                      title: AppLocalizations.of(context)!.nearbyShelters,
                    icon: LucideIcons.mapPin,
                    color: Colors.blue,
                    onTap: () {
                      context.goNamed('nearby_shelters');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                      title: AppLocalizations.of(context)!.emergencySos,
                    icon: LucideIcons.alertOctagon,
                    color: Colors.red,
                    onTap: () {
                      context.goNamed('sos_page');
                    },
                    isEmphasis: true,
                  ),
                  _buildDashboardCard(
                    context,
                      title: AppLocalizations.of(context)!.askForSupport,
                    icon: LucideIcons.helpCircle,
                    color: Colors.green,
                    onTap: () {
                      context.goNamed('needy_view');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                      title: AppLocalizations.of(context)!.chatbotCare,
                    icon: LucideIcons.messageCircle,
                    color: Colors.purple,
                    onTap: () {
                      context.goNamed('chatbot_care');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: AppLocalizations.of(context)!.floodAlerts,
                    icon: LucideIcons.droplets,
                    color: Colors.cyan,
                    onTap: () {
                      context.goNamed('flood_alerts');
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Earthquake Alerts',
                    icon: LucideIcons.waves,
                    color: Colors.red.shade700,
                    onTap: () {
                      context.goNamed('earthquake_alerts');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- UI Enhancement 4: Filling Empty Space with Actionable Content ---
            _buildQuickTipCard(context),

            const SizedBox(height: 16), // Padding at the bottom
          ],
        ),
      ),
    );
  }

  // New widget for the Quick Tip Card
  Widget _buildQuickTipCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.lightBlue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              LucideIcons.feather, // A calming or informational icon
              color: Colors.lightBlue.shade700,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.safetyTip,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.safetyTipContent,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card builder function (remains the same as previous update)
  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEmphasis = false,
  }) {
    final double elevation = isEmphasis ? 12 : 3;
    final Color shadowColor = isEmphasis
        ? color.withValues(alpha: 0.6)
        : Colors.black12;
    final Color cardBackgroundColor = isEmphasis
        ? color.withValues(alpha: 0.15)
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: elevation,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isEmphasis
              ? BorderSide(color: color.withValues(alpha: 0.7), width: 3.0)
              : BorderSide.none,
        ),
        color: cardBackgroundColor,
        child: Container(
          decoration: isEmphasis
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  gradient: LinearGradient(
                    colors: [Colors.white, color.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isEmphasis ? 52 : 40, color: color),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: isEmphasis ? 17 : 15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}