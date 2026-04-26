import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:source_academique/core/constants/app_colors.dart';
import 'package:source_academique/core/constants/ui_dimensions.dart';
import '../../../../core/theme/glass_morphism.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Simulation de messages
  final List<Map<String, dynamic>> _messages = [
    {
      "isUser": false,
      "text": "Bonjour ! Je suis ton assistant académique. Comment puis-je t'aider dans tes révisions aujourd'hui ?",
      "time": "10:00"
    },
  ];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add({
        "isUser": true,
        "text": _controller.text,
        "time": DateTime.now().toString().substring(11, 16)
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Assistant IA", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded, // Icône style moderne
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/'); // 👈 Si on est arrivé ici directement (ex: lien profond ou restart)
            }
          },
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history_rounded)),
        ],
      ),
      body: Column(
        children: [
          // 1. Zone des messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(UiDimensions.paddingLarge),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(
                  message: msg["text"],
                  isUser: msg["isUser"],
                  time: msg["time"],
                  isDark: isDark,
                );
              },
            ),
          ),

          // 2. Zone de saisie (Input Area)
          _buildInputArea(isDark),
          
          // Espace pour ne pas être caché par la barre de navigation
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.attachment_rounded, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: const InputDecoration(
                hintText: "Posez une question...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              backgroundColor: isDark ? AppColors.secondary : const Color(0xFF004D40),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String time;
  final bool isDark;

  const _ChatBubble({
    required this.message,
    required this.isUser,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser 
              ? (isDark ? AppColors.secondary : const Color(0xFF004D40))
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isUser ? 15 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
          border: isUser ? null : Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 9,
                color: isUser ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}