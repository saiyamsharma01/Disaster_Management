import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sahaaya/services/credit_service.dart';

class NeedyViewPage extends StatefulWidget {
  const NeedyViewPage({super.key});

  @override
  State<NeedyViewPage> createState() => _NeedyViewPageState();
}

class _NeedyViewPageState extends State<NeedyViewPage> {
  int _userCredits = 0;
  bool _isLoadingCredits = true;

  @override
  void initState() {
    super.initState();
    _loadUserCredits();
  }

  Future<void> _loadUserCredits() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final credits = await CreditService.getUserCredits(user.uid);
        setState(() {
          _userCredits = credits;
          _isLoadingCredits = false;
        });
      } else {
        setState(() {
          _isLoadingCredits = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCredits = false;
      });
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.chartLine, color: Colors.blue),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Needy View Dashboard',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Credit display - responsive
          if (MediaQuery.of(context).size.width > 400) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.coins, color: Colors.amber.shade700, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _isLoadingCredits ? '...' : '$_userCredits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Compact version for smaller screens
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Icon(
                FontAwesomeIcons.coins, 
                color: Colors.amber.shade700, 
                size: 16,
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.goNamed('needy_view');
              _loadUserCredits();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ivr_responses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.goNamed('needy_view'),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final responses = snapshot.data?.docs ?? [];
          
          return Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width > 500 ? 16 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with stats
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width > 500 ? 16 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live IVR Response Dashboard',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This dashboard shows real-time data from IVR calls. '
                          'When someone presses 1/2/3 on the IVR keypad, it appears here instantly.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        // Credit system info - responsive
                        Container(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 500 ? 16 : 12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 500) {
                                // Desktop layout
                                return Row(
                                  children: [
                                    Icon(FontAwesomeIcons.coins, color: Colors.amber.shade600, size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Credit System',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Earn credits for each IVR choice: Emergency (5), Food/Shelter (3), Volunteer (10)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!_isLoadingCredits)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.amber.shade300),
                                        ),
                                        child: Text(
                                          '$_userCredits Credits',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade800,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              } else {
                                // Mobile layout
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(FontAwesomeIcons.coins, color: Colors.amber.shade600, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Credit System',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade800,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (!_isLoadingCredits)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.amber.shade300),
                                            ),
                                            child: Text(
                                              '$_userCredits',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber.shade800,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Emergency (5) • Food/Shelter (3) • Volunteer (10)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.amber.shade700,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Responsive statistics grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 800) {
                              // Desktop layout - 4 columns
                              return Row(
                                children: [
                                  _StatCard(
                                    title: 'Total Responses',
                                    value: responses.length.toString(),
                                    color: Colors.blue,
                                    icon: FontAwesomeIcons.phone,
                                  ),
                                  const SizedBox(width: 16),
                                  _StatCard(
                                    title: 'Emergencies (1)',
                                    value: responses
                                        .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 1)
                                        .length
                                        .toString(),
                                    color: Colors.red,
                                    icon: FontAwesomeIcons.triangleExclamation,
                                  ),
                                  const SizedBox(width: 16),
                                  _StatCard(
                                    title: 'Food/Shelter (2)',
                                    value: responses
                                        .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 2)
                                        .length
                                        .toString(),
                                    color: Colors.orange,
                                    icon: FontAwesomeIcons.house,
                                  ),
                                  const SizedBox(width: 16),
                                  _StatCard(
                                    title: 'Volunteers (3)',
                                    value: responses
                                        .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 3)
                                        .length
                                        .toString(),
                                    color: Colors.green,
                                    icon: FontAwesomeIcons.userGroup,
                                  ),
                                ],
                              );
                            } else if (constraints.maxWidth > 600) {
                              // Tablet layout - 2x2 grid
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      _StatCard(
                                        title: 'Total Responses',
                                        value: responses.length.toString(),
                                        color: Colors.blue,
                                        icon: FontAwesomeIcons.phone,
                                      ),
                                      const SizedBox(width: 16),
                                      _StatCard(
                                        title: 'Emergencies (1)',
                                        value: responses
                                            .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 1)
                                            .length
                                            .toString(),
                                        color: Colors.red,
                                        icon: FontAwesomeIcons.triangleExclamation,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _StatCard(
                                        title: 'Food/Shelter (2)',
                                        value: responses
                                            .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 2)
                                            .length
                                            .toString(),
                                        color: Colors.orange,
                                        icon: FontAwesomeIcons.house,
                                      ),
                                      const SizedBox(width: 16),
                                      _StatCard(
                                        title: 'Volunteers (3)',
                                        value: responses
                                            .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 3)
                                            .length
                                            .toString(),
                                        color: Colors.green,
                                        icon: FontAwesomeIcons.userGroup,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              // Mobile layout - single column
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _StatCard(
                                          title: 'Total',
                                          value: responses.length.toString(),
                                          color: Colors.blue,
                                          icon: FontAwesomeIcons.phone,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _StatCard(
                                          title: 'Emergency',
                                          value: responses
                                              .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 1)
                                              .length
                                              .toString(),
                                          color: Colors.red,
                                          icon: FontAwesomeIcons.triangleExclamation,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _StatCard(
                                          title: 'Food/Shelter',
                                          value: responses
                                              .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 2)
                                              .length
                                              .toString(),
                                          color: Colors.orange,
                                          icon: FontAwesomeIcons.house,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _StatCard(
                                          title: 'Volunteer',
                                          value: responses
                                              .where((r) => (r.data() as Map<String, dynamic>)['choice'] == 3)
                                              .length
                                              .toString(),
                                          color: Colors.green,
                                          icon: FontAwesomeIcons.userGroup,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Recent responses list
                Expanded(
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 500 ? 16 : 12),
                          child: Text(
                            'Recent IVR Responses',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),
                        if (responses.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone_disabled, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No IVR responses yet',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Try the IVR keypad to generate some data!',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: responses.length,
                              itemBuilder: (context, index) {
                                final doc = responses[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final choice = data['choice'] as int? ?? 0;
                                final phoneNumber = data['phoneNumber'] as String? ?? 'Unknown';
                                final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                                
                                return _ResponseTile(
                                  choice: choice,
                                  phoneNumber: phoneNumber,
                                  timestamp: timestamp,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width > 500 ? 16 : 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: MediaQuery.of(context).size.width > 500 ? 32 : 24),
            SizedBox(height: MediaQuery.of(context).size.width > 500 ? 8 : 6),
            Text(
              value,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 500 ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 500 ? 12 : 10,
                color: color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseTile extends StatelessWidget {
  final int choice;
  final String phoneNumber;
  final DateTime timestamp;

  const _ResponseTile({
    required this.choice,
    required this.phoneNumber,
    required this.timestamp,
  });

  String get _choiceText {
    switch (choice) {
      case 1:
        return 'Emergency Report';
      case 2:
        return 'Food/Shelter Need';
      case 3:
        return 'Volunteer Request';
      default:
        return 'Unknown';
    }
  }

  Color get _choiceColor {
    switch (choice) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get _choiceIcon {
    switch (choice) {
      case 1:
        return FontAwesomeIcons.triangleExclamation;
      case 2:
        return FontAwesomeIcons.house;
      case 3:
        return FontAwesomeIcons.userGroup;
      default:
        return FontAwesomeIcons.question;
    }
  }

  int _getCreditAmount(int choice) {
    switch (choice) {
      case 1:
        return CreditService.emergencyReportCredit;
      case 2:
        return CreditService.foodShelterCredit;
      case 3:
        return CreditService.volunteerRequestCredit;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _choiceColor.withValues(alpha: 0.2),
        child: Icon(_choiceIcon, color: _choiceColor),
      ),
      title: Text(_choiceText),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phone: $phoneNumber'),
          Text(
            '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      trailing: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 400) {
            // Full layout for larger screens
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Credit earned indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.coins, size: 12, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        _getCreditAmount(choice).toString(),
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _choiceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _choiceColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Saved',
                    style: TextStyle(
                      color: _choiceColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context.goNamed('report_map', pathParameters: {'choice': '$choice'});
                  },
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _choiceColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            );
          } else {
            // Compact layout for smaller screens
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Credit indicator - more compact
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.coins, size: 8, color: Colors.amber.shade700),
                      const SizedBox(width: 1),
                      Text(
                        _getCreditAmount(choice).toString(),
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // View button - more compact
                ElevatedButton(
                  onPressed: () {
                    context.goNamed('report_map', pathParameters: {'choice': '$choice'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _choiceColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: const Size(50, 24),
                  ),
                  child: const Text('View', style: TextStyle(fontSize: 8)),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
