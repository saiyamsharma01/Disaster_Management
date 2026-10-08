import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sahaaya/l10n/app_localizations.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  static const _primaryColor = Color(0xFF4F46E5);
  static const _secondaryColor = Color(0xFF7C3AED);
  static const _darkTextColor = Color(0xFF0F172A);
  static const _mutedColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _darkTextColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
          tooltip: 'Back',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 8),

                      // Center Hero Content
                      Column(
                        children: [
                          // 3D App Logo with subtle glow
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withValues(alpha: 0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.asset(
                                'assets/images/sahaaya_logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // App Title & Tagline
                          Text(
                            t.welcomeTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: _darkTextColor,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            t.welcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: _mutedColor,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Feature highlights
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _featureRow(
                                  icon: Icons.emergency_rounded,
                                  color: const Color(0xFFDC2626),
                                  title: 'Instant SOS Radar',
                                  desc: 'Broadcast your live emergency coordinates',
                                ),
                                const Divider(height: 16),
                                _featureRow(
                                  icon: Icons.water_drop_rounded,
                                  color: const Color(0xFF0284C7),
                                  title: 'Live Flood & Seismic Feeds',
                                  desc: 'Real-time hazard telemetry & alerts',
                                ),
                                const Divider(height: 16),
                                _featureRow(
                                  icon: Icons.volunteer_activism_rounded,
                                  color: const Color(0xFF059669),
                                  title: 'Community Aid & Relief',
                                  desc: 'Shelters, rations & volunteer rescue',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Bottom CTAs
                      Column(
                        children: [
                          // Sign In Button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_primaryColor, _secondaryColor],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => context.goNamed('login'),
                                child: Center(
                                  child: Text(
                                    t.login,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () => context.goNamed('signup'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _primaryColor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                t.signUp,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _featureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _darkTextColor,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: _mutedColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
