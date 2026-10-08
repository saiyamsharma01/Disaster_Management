import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:sahaaya/services/credit_service.dart';

class NeedyViewPage extends StatefulWidget {
  const NeedyViewPage({super.key});

  @override
  State<NeedyViewPage> createState() => _NeedyViewPageState();
}

class _NeedyViewPageState extends State<NeedyViewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userCredits = 0;
  bool _isLoadingCredits = true;

  // Form State for "Ask for Support"
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _peopleCountController = TextEditingController(text: '1');

  int _selectedCategory = 1; // 1: Emergency, 2: Food & Shelter, 3: Volunteer
  String _urgencyLevel = 'High'; // 'Critical', 'High', 'Medium', 'Normal'
  bool _isSubmitting = false;
  bool _isLocating = false;

  static const _primaryColor = Color(0xFF4F46E5);
  static const _secondaryColor = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserInfo();
    _loadUserCredits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _peopleCountController.dispose();
    super.dispose();
  }

  void _loadUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _nameController.text = user.displayName!;
      }
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        _phoneController.text = user.phoneNumber!;
      }
    }
  }

  Future<void> _loadUserCredits({bool force = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final credits = await CreditService.getUserCredits(user.uid, forceRefresh: force);
        if (mounted) {
          setState(() {
            _userCredits = credits;
            _isLoadingCredits = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingCredits = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCredits = false);
    }
  }

  Future<void> _fetchGPSLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      // 1. Try instant last known position
      final lastPos = await geolocator.Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        _addressController.text =
            'Lat: ${lastPos.latitude.toStringAsFixed(4)}, Lng: ${lastPos.longitude.toStringAsFixed(4)}';
        setState(() => _isLocating = false);
        return;
      }

      // 2. Query current position with 4s timeout
      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
      }

      if (permission == geolocator.LocationPermission.always ||
          permission == geolocator.LocationPermission.whileInUse) {
        final pos = await geolocator.Geolocator.getCurrentPosition(
          locationSettings: const geolocator.LocationSettings(
            accuracy: geolocator.LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );
        if (mounted) {
          setState(() {
            _addressController.text =
                'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
            _isLocating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📍 GPS location detected!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) setState(() => _isLocating = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'anonymous_user';

      final requestData = {
        'name': _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'Citizen',
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'choice': _selectedCategory,
        'urgency': _urgencyLevel,
        'peopleCount': int.tryParse(_peopleCountController.text.trim()) ?? 1,
        'notes': _notesController.text.trim(),
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending Help',
      };

      // 1. Save to support_requests collection
      await FirebaseFirestore.instance
          .collection('support_requests')
          .add(requestData);

      // 2. Also save to ivr_responses so it appears in the unified live feed
      await FirebaseFirestore.instance.collection('ivr_responses').add({
        'phoneNumber': _phoneController.text.trim(),
        'choice': _selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'notes': _notesController.text.trim(),
        'address': _addressController.text.trim(),
      });

      // 3. Award credits
      if (user != null) {
        await CreditService.awardCreditsForIVRChoice(user.uid, _selectedCategory);
        await _loadUserCredits(force: true);
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        _notesController.clear();

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                SizedBox(width: 8),
                Text('Request Broadcasted'),
              ],
            ),
            content: const Text(
              'Your emergency support request has been logged and sent to nearby volunteers and response teams.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _tabController.animateTo(1);
                },
                child: const Text('View Live Feed'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
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
        title: const Row(
          children: [
            Icon(Icons.volunteer_activism_rounded, color: Color(0xFF059669), size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Support Portal',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Coins indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FontAwesomeIcons.coins, color: Color(0xFFD97706), size: 14),
                const SizedBox(width: 6),
                Text(
                  _isLoadingCredits ? '...' : '$_userCredits',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primaryColor,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: _primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.add_alert_rounded, size: 20), text: 'Request Help'),
            Tab(icon: Icon(Icons.stream_rounded, size: 20), text: 'Live Feed'),
            Tab(icon: Icon(Icons.stars_rounded, size: 20), text: 'Credits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestHelpTab(),
          _buildLiveFeedTab(),
          _buildCreditsTab(),
        ],
      ),
    );
  }

  // ================= TAB 1: REQUEST HELP FORM =================
  Widget _buildRequestHelpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.emergency_rounded, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Immediate Assistance?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fill details below. Nearby rescue teams and volunteers will be notified instantly.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '1. Select Support Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            // Category Options
            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    choice: 1,
                    title: 'Emergency',
                    icon: FontAwesomeIcons.triangleExclamation,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCategoryCard(
                    choice: 2,
                    title: 'Food / Shelter',
                    icon: FontAwesomeIcons.house,
                    color: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCategoryCard(
                    choice: 3,
                    title: 'Volunteer',
                    icon: FontAwesomeIcons.userGroup,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              '2. Urgency Level',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            // Urgency Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Critical', 'High', 'Medium', 'Normal'].map((level) {
                final isSelected = _urgencyLevel == level;
                Color chipColor;
                if (level == 'Critical') {
                  chipColor = const Color(0xFFDC2626);
                } else if (level == 'High') {
                  chipColor = const Color(0xFFEA580C);
                } else if (level == 'Medium') {
                  chipColor = const Color(0xFFD97706);
                } else {
                  chipColor = const Color(0xFF2563EB);
                }

                return ChoiceChip(
                  label: Text(level),
                  selected: isSelected,
                  selectedColor: chipColor.withValues(alpha: 0.15),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? chipColor : const Color(0xFF475569),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? chipColor : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.8 : 1.2,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _urgencyLevel = level);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              '3. Contact & Location Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Your Name (Optional)', Icons.person_outline_rounded),
            ),
            const SizedBox(height: 12),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Contact Phone Number *', Icons.phone_outlined),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Please enter a contact number' : null,
            ),
            const SizedBox(height: 12),

            // Address & GPS Auto-detect
            TextFormField(
              controller: _addressController,
              decoration: _inputDecoration(
                'Location / Landmark / Village *',
                Icons.location_on_outlined,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded, color: _primaryColor),
                  tooltip: 'Get Live GPS',
                  onPressed: _isLocating ? null : _fetchGPSLocation,
                ),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Please enter your location' : null,
            ),
            const SizedBox(height: 12),

            // People Count
            TextFormField(
              controller: _peopleCountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Number of People Affected', Icons.people_outline_rounded),
            ),
            const SizedBox(height: 12),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the emergency need (food, medical urgency, flood rescue)...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _primaryColor, width: 2.0),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitSupportRequest,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.zero,
                  elevation: 4,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            '🚨 Submit Support Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required int choice,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedCategory == choice;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selectedCategory = choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, size: 20, color: _primaryColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryColor, width: 2.0),
      ),
    );
  }

  // ================= TAB 2: LIVE FEED TAB =================
  Widget _buildLiveFeedTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ivr_responses')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int totalCount = docs.length;
        int emergencyCount = 0;
        int foodCount = 0;
        int volunteerCount = 0;

        for (final doc in docs) {
          final data = doc.data() is Map<String, dynamic>
              ? doc.data() as Map<String, dynamic>
              : <String, dynamic>{};
          final c = data['choice'] is num
              ? (data['choice'] as num).toInt()
              : int.tryParse(data['choice']?.toString() ?? '0') ?? 0;

          if (c == 1) emergencyCount++;
          if (c == 2) foodCount++;
          if (c == 3) volunteerCount++;
        }

        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Row
              Row(
                children: [
                  _buildStatItem('Total', '$totalCount', const Color(0xFF2563EB), Icons.list_alt_rounded),
                  const SizedBox(width: 8),
                  _buildStatItem('Emergency', '$emergencyCount', const Color(0xFFDC2626), Icons.warning_rounded),
                  const SizedBox(width: 8),
                  _buildStatItem('Food/Shelter', '$foodCount', const Color(0xFFD97706), Icons.home_rounded),
                  const SizedBox(width: 8),
                  _buildStatItem('Volunteers', '$volunteerCount', const Color(0xFF059669), Icons.handshake_rounded),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Community Requests',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    '${docs.length} active',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Expanded(
                child: docs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.inbox_rounded, size: 50, color: Color(0xFF94A3B8)),
                            SizedBox(height: 10),
                            Text('No active requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() is Map<String, dynamic>
                              ? doc.data() as Map<String, dynamic>
                              : <String, dynamic>{};

                          final choice = data['choice'] is num
                              ? (data['choice'] as num).toInt()
                              : int.tryParse(data['choice']?.toString() ?? '0') ?? 0;
                          final phone = data['phoneNumber']?.toString() ?? 'Unknown';
                          final notes = data['notes']?.toString();
                          final address = data['address']?.toString();

                          DateTime timestamp = DateTime.now();
                          if (data['timestamp'] is Timestamp) {
                            timestamp = (data['timestamp'] as Timestamp).toDate();
                          }

                          return _buildFeedCard(
                            choice: choice,
                            phoneNumber: phone,
                            timestamp: timestamp,
                            notes: notes,
                            address: address,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCard({
    required int choice,
    required String phoneNumber,
    required DateTime timestamp,
    String? notes,
    String? address,
  }) {
    String typeTitle;
    Color typeColor;
    IconData typeIcon;

    switch (choice) {
      case 1:
        typeTitle = 'Emergency Need';
        typeColor = const Color(0xFFDC2626);
        typeIcon = FontAwesomeIcons.triangleExclamation;
        break;
      case 2:
        typeTitle = 'Food / Shelter Request';
        typeColor = const Color(0xFFD97706);
        typeIcon = FontAwesomeIcons.house;
        break;
      case 3:
        typeTitle = 'Volunteer Assistance';
        typeColor = const Color(0xFF059669);
        typeIcon = FontAwesomeIcons.userGroup;
        break;
      default:
        typeTitle = 'General Assistance';
        typeColor = const Color(0xFF2563EB);
        typeIcon = Icons.help_outline_rounded;
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeTitle,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${timestamp.day}/${timestamp.month} · ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.map_rounded, size: 14),
                  label: const Text('Map', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    context.pushNamed('report_map', pathParameters: {'choice': '$choice'});
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_rounded, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  phoneNumber,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            if (address != null && address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF4F46E5)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notes,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= TAB 3: CREDITS & REWARDS =================
  Widget _buildCreditsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFEA580C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sahaaya Reward Coins',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(FontAwesomeIcons.coins, color: Colors.amber.shade200, size: 22),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _isLoadingCredits ? '...' : '$_userCredits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Earned by participating in disaster relief & reporting distress.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'How to Earn Credits:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          _buildCreditInfoCard(
            title: 'Volunteer / Rescue Help',
            amount: '+10 Coins',
            desc: 'Offer volunteering help or assist rescue coordination.',
            color: const Color(0xFF059669),
            icon: FontAwesomeIcons.userGroup,
          ),
          const SizedBox(height: 8),

          _buildCreditInfoCard(
            title: 'Emergency Distress Reporting',
            amount: '+5 Coins',
            desc: 'Report genuine emergency situations in your vicinity.',
            color: const Color(0xFFDC2626),
            icon: FontAwesomeIcons.triangleExclamation,
          ),
          const SizedBox(height: 8),

          _buildCreditInfoCard(
            title: 'Food / Shelter Request',
            amount: '+3 Coins',
            desc: 'Submit food, ration, or shelter requirements.',
            color: const Color(0xFFD97706),
            icon: FontAwesomeIcons.house,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditInfoCard({
    required String title,
    required String amount,
    required String desc,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      amount,
                      style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 12.5),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
