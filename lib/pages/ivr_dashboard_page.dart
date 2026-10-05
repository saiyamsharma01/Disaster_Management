// lib/pages/ivr_dashboard_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class IvrDashboardPage extends StatelessWidget {
  const IvrDashboardPage({super.key});

  static const String collectionName = 'ivr_call_logs';

  Stream<QuerySnapshot<Map<String, dynamic>>> _callStream() {
    return FirebaseFirestore.instance
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .limit(250)
        .snapshots();
  }

  static const Map<String, Color> optionColors = {
    'Emergency Response': Color(0xFFE53935),
    'HIV/AIDS Support': Color(0xFF6A1B9A),
    'Volunteer Coordination': Color(0xFF1E88E5),
    'Unknown Selection': Color(0xFF546E7A),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 1024;

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
        title: const Text('IVR Live Call Dashboard'),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _callStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load call records.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }

          final records = snapshot.data?.docs
                  .map((doc) {
                    try {
                      return CallRecord.fromFirestore(doc);
                    } catch (_) {
                      return null;
                    }
                  })
                  .whereType<CallRecord>()
                  .toList() ??
              [];

          final totals = CallRecord.totalsByOption(records);
          final totalCalls = records.length;
          final validCalls = records.where((record) => record.isValid).length;
          final invalidCalls = totalCalls - validCalls;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Flex(
                direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: isLargeScreen ? 2 : 0,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        MetricCard(
                          title: 'Total Calls (24h)',
                          value: '$totalCalls',
                          color: theme.colorScheme.primary,
                          icon: Icons.timeline,
                        ),
                        MetricCard(
                          title: 'Valid Selections',
                          value: '$validCalls',
                          color: theme.colorScheme.secondary,
                          icon: Icons.check_circle,
                        ),
                        MetricCard(
                          title: 'Invalid Inputs',
                          value: '$invalidCalls',
                          color: theme.colorScheme.error,
                          icon: Icons.error_outline,
                        ),
                        ...totals.entries.map(
                          (entry) => MetricCard(
                            title: entry.key,
                            value: '${entry.value}',
                            color: optionColors[entry.key] ?? theme.primaryColor,
                            icon: Icons.phone_in_talk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24, width: 24),
                  Expanded(
                    flex: 3,
                    child: CallList(records: records),
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

class CallList extends StatefulWidget {
  const CallList({super.key, required this.records});

  final List<CallRecord> records;

  @override
  State<CallList> createState() => _CallListState();
}

class _CallListState extends State<CallList> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _timestampFormat = DateFormat('MMM d, yyyy • HH:mm:ss');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CallRecord> get _filteredRecords {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.records;
    }
    return widget.records.where((record) {
      final combined = [
        record.optionLabel,
        record.optionDigit,
        record.callSid ?? '',
        record.from ?? '',
        record.to ?? '',
      ].join(' ').toLowerCase();
      return combined.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search by option, caller, or Call SID',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No calls recorded yet.'))
              : Scrollbar(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final record = filtered[index];
                      final optionColor =
                          IvrDashboardPage.optionColors[record.optionLabel] ??
                              Theme.of(context).primaryColor;
                      return Card(
                        elevation: 1,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: optionColor.withValues(alpha: 0.12),
                            child: Icon(
                              record.isValid
                                  ? Icons.check_circle
                                  : Icons.help_outline,
                              color: optionColor,
                            ),
                          ),
                          title: Text(
                            record.optionLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(_timestampFormat.format(record.timestamp)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (record.optionDigit != null)
                                    Chip(
                                      label:
                                          Text('Digit ${record.optionDigit}'),
                                      avatar: const Icon(
                                        Icons.dialpad,
                                        size: 16,
                                      ),
                                    ),
                                  if (record.callSid != null)
                                    Chip(
                                      label: Text(
                                        'Call SID: ${record.callSid}',
                                      ),
                                    ),
                                  if (record.from != null)
                                    Chip(
                                      label: Text('From: ${record.from}'),
                                    ),
                                  if (record.to != null)
                                    Chip(
                                      label: Text('To: ${record.to}'),
                                    ),
                                  Chip(
                                    label: Text(record.isValid
                                        ? 'Recorded'
                                        : 'Invalid Input'),
                                    backgroundColor: record.isValid
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : Theme.of(context)
                                            .colorScheme
                                            .errorContainer,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                  ),
                ),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      height: 140,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CallRecord {
  CallRecord({
    required this.id,
    required this.optionLabel,
    required this.timestamp,
    required this.isValid,
    this.optionDigit,
    this.callSid,
    this.from,
    this.to,
  });

  final String id;
  final String optionLabel;
  final DateTime timestamp;
  final bool isValid;
  final String? optionDigit;
  final String? callSid;
  final String? from;
  final String? to;

  static const Map<String, String> fallbackLabels = {
    '1': 'Emergency Response',
    '2': 'HIV/AIDS Support',
    '3': 'Volunteer Coordination',
  };

  static CallRecord fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final createdAt = data['createdAt'] as Timestamp?;
    final timestamp = createdAt?.toDate() ?? DateTime.now();

    final optionLabel = data['optionLabel'] as String?;
    final optionDigit = data['optionDigit']?.toString();
    final isValidSelection =
        data['isValidSelection'] as bool? ?? optionLabel != null;

    final resolvedLabel =
        optionLabel ?? fallbackLabels[optionDigit] ?? 'Unknown Selection';

    return CallRecord(
      id: doc.id,
      optionLabel: resolvedLabel,
      optionDigit: optionDigit,
      timestamp: timestamp,
      callSid: data['callSid'] as String?,
      from: data['from'] as String?,
      to: data['to'] as String?,
      isValid: isValidSelection,
    );
  }

  static Map<String, int> totalsByOption(List<CallRecord> records) {
    final totals = <String, int>{
      'Emergency Response': 0,
      'HIV/AIDS Support': 0,
      'Volunteer Coordination': 0,
      'Unknown Selection': 0,
    };

    for (final record in records) {
      totals.update(
        record.optionLabel,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return totals;
  }
}
