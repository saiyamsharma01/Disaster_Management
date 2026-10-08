import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sahaaya/services/credit_service.dart';

class IVRDemoPage extends StatefulWidget {
  const IVRDemoPage({super.key});

  @override
  State<IVRDemoPage> createState() => _IVRDemoPageState();
}

class _IVRDemoPageState extends State<IVRDemoPage> {
  final String _dummyNumber = "+918360671237";
  bool _isSaving = false;

  Future<User?> _ensureAuth() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser;
    try {
      final credential = await auth.signInAnonymously();
      return credential.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveChoice(int choice) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final user = await _ensureAuth();
      final uid = user?.uid ?? 'anonymous_ivr';

      // 1. Save IVR response
      await FirebaseFirestore.instance.collection('ivr_responses').add({
        'phoneNumber': _dummyNumber,
        'choice': choice,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': uid,
      });

      // 2. Award credits
      if (user != null) {
        await CreditService.awardCreditsForIVRChoice(user.uid, choice);
      }

      int currentCredits = user != null ? await CreditService.getUserCredits(user.uid) : 0;

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    choice == 1 ? FontAwesomeIcons.triangleExclamation : 
                    choice == 2 ? FontAwesomeIcons.house : 
                    FontAwesomeIcons.userGroup,
                    color: choice == 1 ? Colors.red : 
                           choice == 2 ? Colors.orange : Colors.green,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Text('Response Recorded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your keypad selection has been logged into the live disaster net.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(FontAwesomeIcons.coins, color: Color(0xFF059669), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Credits Awarded! Current Balance: $currentCredits Coins',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.pushNamed(
                      'ivr_outcome',
                      pathParameters: {'choice': '$choice'},
                    );
                  },
                  child: const Text('View Sector Map'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text(
          'IVR Emergency Keypad',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '1800-SAHAAYA',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Offline Interactive Voice Keypad Simulator.\nPress 1, 2, or 3 to trigger simulated distress.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Phone shell
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Screen Area
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Connected: Toll-Free Relief Net',
                              style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Keypad rows
                      _keyRow([
                        _KeySpec('1', 'Emergency', const Color(0xFFEF4444), () => _saveChoice(1), FontAwesomeIcons.triangleExclamation),
                        _KeySpec('2', 'Food/Shelter', const Color(0xFFF59E0B), () => _saveChoice(2), FontAwesomeIcons.house),
                        _KeySpec('3', 'Volunteer', const Color(0xFF10B981), () => _saveChoice(3), FontAwesomeIcons.userGroup),
                      ]),
                      const SizedBox(height: 12),
                      _keyRow([
                        _KeySpec('4', '', Colors.white24, null, null),
                        _KeySpec('5', '', Colors.white24, null, null),
                        _KeySpec('6', '', Colors.white24, null, null),
                      ]),
                      const SizedBox(height: 12),
                      _keyRow([
                        _KeySpec('7', '', Colors.white24, null, null),
                        _KeySpec('8', '', Colors.white24, null, null),
                        _KeySpec('9', '', Colors.white24, null, null),
                      ]),
                      const SizedBox(height: 12),
                      _keyRow([
                        _KeySpec('*', '', Colors.white24, null, null),
                        _KeySpec('0', '', Colors.white24, null, null),
                        _KeySpec('#', '', Colors.white24, null, null),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeySpec {
  final String label;
  final String sub;
  final Color color;
  final VoidCallback? onTap;
  final IconData? icon;
  _KeySpec(this.label, this.sub, this.color, this.onTap, this.icon);
}

Widget _keyRow(List<_KeySpec> keys) {
  return Row(
    children: keys
        .map((k) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                  onTap: k.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: k.color.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (k.icon != null) Icon(k.icon, size: 14, color: k.color),
                        Text(
                          k.label,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        if (k.sub.isNotEmpty)
                          Text(
                            k.sub,
                            style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ))
        .toList(),
  );
}
