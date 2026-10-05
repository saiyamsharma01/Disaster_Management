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
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _addWelcomeMessage();
  }

  void _initializeGemini() {
    try {
      // Initialize Gemini with your API key
      _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: 'AIzaSyCDWdr8p-pf_HikPhXePN9AoZQZbO_cff0',
        systemInstruction: Content.system(
          'You are a Natural Disaster Expert AI Assistant specialized in helping people during emergencies and disasters. '
          'You provide expert advice on:\n'
          '- Emergency preparedness and safety measures\n'
          '- Disaster response and evacuation procedures\n'
          '- First aid and medical assistance during disasters\n'
          '- Resource management during emergencies\n'
          '- Communication with emergency services\n'
          '- Psychological support for disaster victims\n\n'
          'Always prioritize safety and direct users to contact local emergency services (911, 100, etc.) for immediate help. '
          'Provide clear, actionable advice and maintain a calm, supportive tone. '
          'If you cannot provide specific medical or emergency advice, always recommend contacting professional emergency services.'
        ),
      );
      print('Gemini model initialized successfully');
    } catch (e) {
      print('Error initializing Gemini: $e');
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: "⚠️ MEDICAL DISCLAIMER: I am an AI assistant and NOT a substitute for professional medical advice, diagnosis, or treatment. Always consult qualified healthcare professionals for medical emergencies.\n\nHello! I'm your Natural Disaster Expert AI Assistant. I'm here to help you with emergency preparedness, disaster response, and safety guidance. How can I assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _addFallbackResponse(String userMessage) {
    // Provide basic fallback responses for common disaster-related questions
    String fallbackResponse = "";
    String lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('earthquake') || lowerMessage.contains('bhukamp')) {
      fallbackResponse = "🏚️ EARTHQUAKE SAFETY:\n\n"
          "1️⃣ Drop, Cover, and Hold On\n"
          "2️⃣ Stay away from windows and heavy objects\n"
          "3️⃣ If outdoors, move to an open area\n"
          "4️⃣ After shaking stops, check for injuries and damage\n\n"
          "📞 Call emergency services (100/911) if needed.";
    } else if (lowerMessage.contains('flood') || lowerMessage.contains('barrish') || lowerMessage.contains('paani')) {
      fallbackResponse = "🌊 FLOOD SAFETY:\n\n"
          "1️⃣ Move to higher ground immediately\n"
          "2️⃣ Avoid walking or driving through floodwaters\n"
          "3️⃣ Turn off electricity and gas\n"
          "4️⃣ Keep emergency supplies ready\n"
          "5️⃣ Follow evacuation orders\n\n"
          "📞 Call 100 for emergency help.\n\n"
          "💡 TIP: Just 6 inches of moving water can knock you down, and 1 foot of water can sweep away a vehicle.";
    } else if (lowerMessage.contains('fire') || lowerMessage.contains('aag')) {
      fallbackResponse = "🔥 FIRE SAFETY:\n\n"
          "1️⃣ Get out immediately and call 101 (fire department)\n"
          "2️⃣ Use stairs, not elevators\n"
          "3️⃣ Stay low if there's smoke\n"
          "4️⃣ Stop, drop, and roll if clothes catch fire\n"
          "5️⃣ Never go back inside a burning building\n\n"
          "📞 Emergency: 101";
    } else if (lowerMessage.contains('help') || lowerMessage.contains('emergency') || lowerMessage.contains('madad')) {
      fallbackResponse = "🆘 EMERGENCY CONTACTS:\n\n"
          "🚔 Police - 100\n"
          "🚒 Fire - 101\n"
          "🏥 Medical - 102\n"
          "⛑️ Disaster Management - 108\n\n"
          "Stay calm and provide your location clearly.";
    } else if (lowerMessage.contains('preparedness') || lowerMessage.contains('taiyari')) {
      fallbackResponse = "📦 EMERGENCY PREPAREDNESS:\n\n"
          "1️⃣ Keep emergency kit ready (water, food, first aid, flashlight)\n"
          "2️⃣ Know evacuation routes\n"
          "3️⃣ Have important documents ready\n"
          "4️⃣ Keep emergency contacts handy\n"
          "5️⃣ Practice emergency drills with family\n\n"
          "💡 Update your kit every 6 months!";
    } else {
      fallbackResponse =
      "🤖 I'm here to help with disaster preparedness and emergency response.\n\n"
          "I can assist with:\n"
          "• 🌊 Floods\n"
          "• 🏚️ Earthquakes\n"
          "• 🔥 Fires\n"
          "• 📦 Emergency preparedness\n\n"
          "For immediate help, call emergency services at 100, 101, or 102.";
    }
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: fallbackResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    try {
      final response = await _model.generateContent([Content.text(userMessage)]);
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: response.text ?? "I'm sorry, I couldn't process your request. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Gemini API Error: $e'); // Debug print
      setState(() {
        _isLoading = false;
      });

      // Add a helpful fallback response directly without error message
      _addFallbackResponse(userMessage);
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
          children: [
            Icon(FontAwesomeIcons.robot, color: Colors.blue),
            SizedBox(width: 10),
            Text('Chatbot Care'),
          ],
        ),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Column(
        children: [
          // Medical Disclaimer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.orange.shade200, width: 2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700,
                    size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Assistant - Not a medical professional. Always consult doctors for medical advice.',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Chat messages
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
          
          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('AI is thinking...'),
                ],
              ),
            ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about emergency preparedness, disaster response...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  mini: true,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(
                FontAwesomeIcons.robot,
                size: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue.shade500 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message.isUser 
                      ? const Radius.circular(18) 
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white 
                          : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white70 
                          : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade500,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
