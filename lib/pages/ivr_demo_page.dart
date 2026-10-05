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

  Future<User?> _ensureAnonymousAuth() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser;
    try {
      final credential = await auth.signInAnonymously();
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  void _showReportDialog(int choice) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                choice == 1 ? FontAwesomeIcons.triangleExclamation : 
                choice == 2 ? FontAwesomeIcons.house : 
                FontAwesomeIcons.userGroup,
                color: choice == 1 ? Colors.red : 
                       choice == 2 ? Colors.orange : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text('Report Submitted'),
            ],
          ),
          content: Text(
            'Your report was added. I will immediately help you.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveChoice(int choice) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final user = await _ensureAnonymousAuth();
      if (user == null) throw Exception('Auth failed');

      // Save IVR response
      await FirebaseFirestore.instance.collection('ivr_responses').add({
        'phoneNumber': _dummyNumber,
        'choice': choice,
        'timestamp': DateTime.now(),
        'userId': user.uid,
      });

      // Award credits based on choice
      bool creditsAwarded = await CreditService.awardCreditsForIVRChoice(user.uid, choice);
      
      // Get current credit balance
      int currentCredits = await CreditService.getUserCredits(user.uid);

      // Show confirmation dialog with credit information
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    choice == 1 ? FontAwesomeIcons.triangleExclamation : 
                    choice == 2 ? FontAwesomeIcons.house : 
                    FontAwesomeIcons.userGroup,
                    color: choice == 1 ? Colors.red : 
                           choice == 2 ? Colors.orange : Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text('Report Submitted'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your report was added. I will immediately help you.',
                    style: TextStyle(fontSize: 16),
                  ),
                  if (creditsAwarded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.coins, color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Credits Earned!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  _getCreditMessage(choice),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                                Text(
                                  'Total Credits: $currentCredits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  String _getCreditMessage(int choice) {
    switch (choice) {
      case 1:
        return 'You earned ${CreditService.emergencyReportCredit} credits for emergency report!';
      case 2:
        return 'You earned ${CreditService.foodShelterCredit} credits for food/shelter request!';
      case 3:
        return 'You earned ${CreditService.volunteerRequestCredit} credits for volunteer request!';
      default:
        return 'Credits earned!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text('IVR Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
             child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Call 1800-XXXX',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'This simulates an IVR (Interactive Voice Response) keypad. Press 1/2/3 to record intent.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
                ),
                 const SizedBox(height: 12),
                 // Quick open outcome map without saving again
                 Wrap(
                   spacing: 8,
                   runSpacing: 8,
                   alignment: WrapAlignment.center,
                   children: [
                     OutlinedButton.icon(
                       onPressed: () => _showReportDialog(1),
                       icon: const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red, size: 16),
                       label: const Text('View Emergencies (1)'),
                     ),
                     OutlinedButton.icon(
                       onPressed: () => _showReportDialog(2),
                       icon: const Icon(FontAwesomeIcons.house, color: Colors.orange, size: 16),
                       label: const Text('View Food/Shelter (2)'),
                     ),
                     OutlinedButton.icon(
                       onPressed: () => _showReportDialog(3),
                       icon: const Icon(FontAwesomeIcons.userGroup, color: Colors.green, size: 16),
                       label: const Text('View Volunteers (3)'),
                     ),
                   ],
                 ),
                const SizedBox(height: 24),

                // Phone-like shell
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Small screen area
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Dialing 759-589-1234...',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Keypad rows (we only need 1/2/3 but show a grid for realism)
                      _keyRow([
                        _KeySpec('1', 'Emergency', Colors.red, () => _saveChoice(1), FontAwesomeIcons.triangleExclamation),
                        _KeySpec('2', 'Food/Shelter', Colors.orange, () => _saveChoice(2), FontAwesomeIcons.house),
                        _KeySpec('3', 'Volunteer', Colors.green, () => _saveChoice(3), FontAwesomeIcons.phone),
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
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: keys
        .map((k) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InkWell(
                  onTap: k.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: k.color.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (k.icon != null) Icon(k.icon, size: 16, color: k.color),
                        Text(k.label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        if (k.sub.isNotEmpty)
                          Text(k.sub, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ))
        .toList(),
  );
}


