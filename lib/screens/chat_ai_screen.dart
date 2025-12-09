// lib/screens/chat_ai_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_service.dart';
import '../widgets/chat_bubble.dart';

class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({Key? key}) : super(key: key);

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String?>> _messages = [];
  bool _isTyping = false;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;

    final text = _controller.text.trim();
    final imagePath = _selectedImage?.path;

    setState(() {
      _messages.add({'role': 'user', 'text': text, 'image': imagePath});
      _isTyping = true;
      _controller.clear();
      _selectedImage = null;
    });

    _scrollToBottom();

    String reply;
    try {
      if (imagePath != null) {
        reply = await AIService().sendImage(File(imagePath));
      } else {
        reply = await AIService().sendPrompt(text);
      }
    } catch (e) {
      reply = "⚠️ Error: $e";
    }

    if (!mounted) return;

    setState(() {
      _messages.add({'role': 'ai', 'text': reply});
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildInput() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _selectedImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.image, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: "Ask AgroXpert AI...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        )
                      ],
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.green,
            child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [DotTyping()],
            ),
          ),
        ],
      ),
    );
  }

  // Full-screen image preview
  void _openFullImage(String imagePath, String text) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              ),
              if (text.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      text,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  "AgroXpert AI Assistant",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/chat_bg.png'),
                fit: BoxFit.cover,
                opacity: 0.03,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    }

                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';

                    return GestureDetector(
                      onTap: () {
                        if (msg['image'] != null) {
                          _openFullImage(msg['image']!, msg['text'] ?? '');
                        }
                      },
                      child: ChatBubble(
                        isUser: isUser,
                        text: msg['text'] ?? '',
                        imagePath: msg['image'],
                        showAvatar: true,
                      ),
                    );
                  },
                ),
              ),
              _buildInput(),
            ],
          ),
        ],
      ),
    );
  }
}

// Typing dots
class DotTyping extends StatefulWidget {
  const DotTyping({super.key});

  @override
  State<DotTyping> createState() => _DotTypingState();
}

class _DotTypingState extends State<DotTyping> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => FadeTransition(
          opacity: _animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
