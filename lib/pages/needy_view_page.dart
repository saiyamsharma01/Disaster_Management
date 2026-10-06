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

  final _primaryColor = const Color(0xFF4A00E0);
  final _secondaryColor = const Color(0xFF8E2DE2);

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

  Future<void> _loadUserCredits() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final credits = await CreditService.getUserCredits(user.uid);
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
    setState(() => _isLocating = true);
    try {
      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
      }

      if (permission == geolocator.LocationPermission.always ||
          permission == geolocator.LocationPermission.whileInUse) {
        final pos = await geolocator.Geolocator.getCurrentPosition(
          locationSettings: const geolocator.LocationSettings(
            accuracy: geolocator.LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
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
              content: Text('📍 Current GPS location detected!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isLocating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch location: $e')),
        );
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
            : 'Anonymous User',
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

      // 2. Also save to ivr_responses so it appears in the live unified dashboard
      await FirebaseFirestore.instance.collection('ivr_responses').add({
        'phoneNumber': _phoneController.text.trim(),
        'choice': _selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'notes': _notesController.text.trim(),
        'address': _addressController.text.trim(),
      });

      // 3. Award credits to the user for submitting a validated report
      if (user != null) {
        await CreditService.awardCreditsForIVRChoice(user.uid, _selectedCategory);
        await _loadUserCredits();
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        _notesController.clear();

        // Show Success Dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Request Submitted'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your emergency support request has been broadcasted to nearby responders and rescue teams.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.coins,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'You earned reward credits for reporting distress!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
                  Navigator.pop(ctx);
                  _tabController.animateTo(1); // Switch to Live Feed
                },
                child: const Text('View Live Feed'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
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
            Icon(Icons.volunteer_activism, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Ask For Support',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Coins Indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade400),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.coins,
                  color: Colors.amber.shade800,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _isLoadingCredits ? '...' : '$_userCredits',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadUserCredits();
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: _primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.add_alert), text: 'Request Help'),
            Tab(icon: Icon(Icons.stream), text: 'Live Feed'),
            Tab(icon: Icon(Icons.stars), text: 'Credits'),
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
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Need Immediate Assistance?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fill details below. Nearby rescue teams and volunteers will be notified instantly.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCategoryCard(
                    choice: 2,
                    title: 'Food / Shelter',
                    icon: FontAwesomeIcons.house,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCategoryCard(
                    choice: 3,
                    title: 'Volunteer',
                    icon: FontAwesomeIcons.userGroup,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              '2. Urgency Level',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Urgency Chips
            Row(
              children: ['Critical', 'High', 'Medium', 'Normal'].map((level) {
                final isSelected = _urgencyLevel == level;
                Color chipColor;
                if (level == 'Critical') {
                  chipColor = Colors.red;
                } else if (level == 'High') {
                  chipColor = Colors.deepOrange;
                } else if (level == 'Medium') {
                  chipColor = Colors.amber.shade800;
                } else {
                  chipColor = Colors.blue;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(level),
                    selected: isSelected,
                    selectedColor: chipColor.withValues(alpha: 0.2),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? chipColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? chipColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _urgencyLevel = level);
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              '3. Contact & Location Information',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Your Name (Optional)', Icons.person),
            ),
            const SizedBox(height: 12),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Contact Phone Number *', Icons.phone),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Please enter a contact number' : null,
            ),
            const SizedBox(height: 12),

            // Address & GPS Auto-detect
            TextFormField(
              controller: _addressController,
              decoration: _inputDecoration(
                'Location / Landmark / Village *',
                Icons.location_on,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, color: Colors.blue),
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
              decoration: _inputDecoration(
                'Number of People Affected',
                Icons.people,
              ),
            ),
            const SizedBox(height: 12),

            // Description / Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the situation (e.g. food needed, medical urgency, flooded house)...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
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
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
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
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ================= TAB 2: LIVE FEED TAB =================
  Widget _buildLiveFeedTab() {
    return StreamBuilder<QuerySnapshot>(
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
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Error loading requests: ${snapshot.error}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

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

          if (c == 1) {
            emergencyCount++;
          } else if (c == 2) {
            foodCount++;
          } else if (c == 3) {
            volunteerCount++;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Row (Safe Layout)
              Row(
                children: [
                  _buildStatItem('Total', '$totalCount', Colors.blue, FontAwesomeIcons.listCheck),
                  const SizedBox(width: 8),
                  _buildStatItem('Emergency', '$emergencyCount', Colors.red, FontAwesomeIcons.triangleExclamation),
                  const SizedBox(width: 8),
                  _buildStatItem('Food/Shelter', '$foodCount', Colors.orange, FontAwesomeIcons.house),
                  const SizedBox(width: 8),
                  _buildStatItem('Volunteer', '$volunteerCount', Colors.green, FontAwesomeIcons.userGroup),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Community Requests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${docs.length} reports',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Request Cards List
              Expanded(
                child: docs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No support requests yet',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use "Request Help" tab to submit an urgent request.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: color),
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
        typeColor = Colors.red;
        typeIcon = FontAwesomeIcons.triangleExclamation;
        break;
      case 2:
        typeTitle = 'Food / Shelter Request';
        typeColor = Colors.orange;
        typeIcon = FontAwesomeIcons.house;
        break;
      case 3:
        typeTitle = 'Volunteer Offer / Request';
        typeColor = Colors.green;
        typeIcon = FontAwesomeIcons.userGroup;
        break;
      default:
        typeTitle = 'General Assistance';
        typeColor = Colors.blue;
        typeIcon = FontAwesomeIcons.circleQuestion;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${timestamp.day}/${timestamp.month}/${timestamp.year} · ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.map, size: 14),
                  label: const Text('Map', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    context.goNamed('report_map', pathParameters: {'choice': '$choice'});
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(
                  phoneNumber,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (address != null && address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  notes,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
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
              gradient: LinearGradient(
                colors: [Colors.amber.shade700, Colors.orange.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(FontAwesomeIcons.coins, color: Colors.amber.shade200, size: 24),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isLoadingCredits ? '...' : '$_userCredits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildCreditInfoCard(
            title: 'Volunteer / Rescue Help',
            amount: '+10 Coins',
            desc: 'Offer volunteering help or assist rescue coordination.',
            color: Colors.green,
            icon: FontAwesomeIcons.userGroup,
          ),
          const SizedBox(height: 10),

          _buildCreditInfoCard(
            title: 'Emergency Distress Reporting',
            amount: '+5 Coins',
            desc: 'Report genuine emergency situations in your vicinity.',
            color: Colors.red,
            icon: FontAwesomeIcons.triangleExclamation,
          ),
          const SizedBox(height: 10),

          _buildCreditInfoCard(
            title: 'Food / Shelter Request',
            amount: '+3 Coins',
            desc: 'Submit food, ration, or shelter requirements.',
            color: Colors.orange,
            icon: FontAwesomeIcons.house,
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.emergency),
                  label: const Text('Request Help Now'),
                  onPressed: () => _tabController.animateTo(0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.phone),
                  label: const Text('Open IVR Demo'),
                  onPressed: () => context.goNamed('ivr_demo'),
                ),
              ),
            ],
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
