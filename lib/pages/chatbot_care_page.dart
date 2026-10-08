import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ChatbotCarePage extends StatefulWidget {
  const ChatbotCarePage({super.key});

  @override
  State<ChatbotCarePage> createState() => _ChatbotCarePageState();
}

class _ChatbotCarePageState extends State<ChatbotCarePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  GenerativeModel? _model;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _addWelcomeMessage();
  }

  void _initializeGemini() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCDWdr8p-pf_HikPhXePN9AoZQZbO_cff0',
        systemInstruction: Content.system(
          'You are a Natural Disaster Expert AI Assistant specialized in helping people during emergencies and disasters. '
          'You provide expert advice on emergency preparedness, safety measures, disaster response, first aid, and evacuation. '
          'Always prioritize safety and direct users to contact local emergency services (112, 100, 108) for immediate danger.'
        ),
      );
    } catch (e) {
      debugPrint('Gemini init info: $e');
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: "Hello! I am your Sahaaya AI Emergency Assistant.\n\nAsk me anything about disaster preparedness, earthquake safety, flood protocols, first aid, or emergency hotlines.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  String _getFallbackResponse(String userMessage) {
    String lower = userMessage.toLowerCase();
    if (lower.contains('earthquake') || lower.contains('bhukamp')) {
      return "🏚️ EARTHQUAKE SAFETY PROTOCOL:\n\n"
          "1️⃣ DROP, COVER, and HOLD ON under sturdy furniture.\n"
          "2️⃣ Stay away from glass windows and heavy objects.\n"
          "3️⃣ If outdoors, move to an open clear ground.\n"
          "4️⃣ After shaking stops, check for gas leaks and structural cracks.\n\n"
          "📞 Emergency helpline: 112 / 1070";
    } else if (lower.contains('flood') || lower.contains('water') || lower.contains('baad') || lower.contains('paani')) {
      return "🌊 FLOOD SAFETY PROTOCOL:\n\n"
          "1️⃣ Move to higher ground immediately.\n"
          "2️⃣ Never walk or drive through flowing water (6 inches can sweep away a person).\n"
          "3️⃣ Switch off main electric circuit breakers.\n"
          "4️⃣ Keep battery radio and clean drinking water ready.\n\n"
          "📞 Disaster Control Room: 1070 / 112";
    } else if (lower.contains('fire') || lower.contains('aag')) {
      return "🔥 FIRE SAFETY PROTOCOL:\n\n"
          "1️⃣ Evacuate immediately — crawl low under smoke.\n"
          "2️⃣ Use stairs, NEVER use elevators.\n"
          "3️⃣ Stop, Drop, and Roll if clothes catch fire.\n\n"
          "📞 Fire Brigade: 101 / 112";
    } else if (lower.contains('help') || lower.contains('emergency') || lower.contains('number') || lower.contains('police')) {
      return "🆘 DIRECT EMERGENCY HELPLINES:\n\n"
          "🚨 National Emergency: 112\n"
          "👮 Police: 100\n"
          "🚒 Fire: 101\n"
          "🚑 Ambulance: 108 / 102\n"
          "🌊 Disaster Management: 1070\n"
          "🧒 Women / Child: 1091 / 1098";
    } else {
      return "🤖 Sahaaya AI Disaster Assistant:\n\n"
          "I can provide immediate guidance for:\n"
          "• 🌊 Flood & Water Level Alerts\n"
          "• 🏚️ Earthquake Drill & Safety\n"
          "• 🔥 Fire Evacuation & First Aid\n"
          "• 📦 Emergency Disaster Kit Checklist\n\n"
          "For direct emergency rescue, dial 112 immediately.";
    }
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _messageController.clear();
    }

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      if (_model != null) {
        final response = await _model!.generateContent([Content.text(text)]).timeout(
          const Duration(seconds: 8),
        );
        final responseText = response.text?.trim();

        if (responseText != null && responseText.isNotEmpty) {
          if (mounted) {
            setState(() {
              _messages.add(
                ChatMessage(
                  text: responseText,
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
              _isLoading = false;
            });
            _scrollToBottom();
            return;
          }
        }
      }
      throw Exception('Fallback triggered');
    } catch (_) {
      final fallback = _getFallbackResponse(text);
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: fallback,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.robot, color: Color(0xFF4F46E5), size: 16),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chatbot Care AI',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '24/7 Disaster Preparedness Guide',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Medical / Emergency Disclaimer Strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBEB),
              border: Border(bottom: BorderSide(color: Color(0xFFFDE68A))),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Safety Guide · For active life-threatening emergencies, dial 112 immediately.',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages ListView
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Thinking Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Sahaaya AI is responding...',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Quick Suggestion Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickChip('🌊 Flood Safety', 'What should I do during a flood?'),
                  const SizedBox(width: 8),
                  _buildQuickChip('🏚️ Earthquake Drill', 'How to protect myself during an earthquake?'),
                  const SizedBox(width: 8),
                  _buildQuickChip('🆘 Emergency Numbers', 'List all emergency contact numbers'),
                  const SizedBox(width: 8),
                  _buildQuickChip('📦 Emergency Kit', 'What items are in an emergency preparedness kit?'),
                ],
              ),
            ),
          ),

          // Text Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Ask for emergency guidance...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: _isLoading ? null : () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, String prompt) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _sendMessage(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.robot, size: 13, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF4F46E5) : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: message.isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: message.isUser ? Colors.white70 : const Color(0xFF94A3B8),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
