import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../utils/platform_utils.dart';

import '../services/ai_service.dart';
import '../services/chat_history_service.dart';
import '../services/agro_context_service.dart';
import '../models/chat_history.dart';
import '../widgets/chat_bubble.dart';
import 'chat_history_screen.dart';
import '../utils/app_localizations.dart';

class ChatAIScreen extends StatefulWidget {
  final ChatHistory? history;
  final bool loadContext; // New parameter to load context automatically
  
  const ChatAIScreen({
    Key? key,
    this.history,
    this.loadContext = false,
  }) : super(key: key);

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String?>> _messages = [];
  final AgroContextService _contextService = AgroContextService();
  bool _isTyping = false;
  XFile? _selectedImage;
  String? _chatId;
  String? _chatTitle;
  final ChatHistoryService _historyService = ChatHistoryService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.history != null) {
      _chatId = widget.history!.id;
      _chatTitle = widget.history!.title;
      _messages.addAll(
        widget.history!.messages.map((m) => {
          'role': m.role,
          'text': m.text,
          'image': m.imagePath,
        }),
      );
    } else {
      _chatId = const Uuid().v4();
    }
    
    // 3. AI CHAT INJECTION - Load context automatically if requested
    if (widget.loadContext && _messages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadContextAndSend();
      });
    }
  }

  /// Load agro context and send it automatically to AI
  Future<void> _loadContextAndSend() async {
    final contextPrompt = _contextService.getChatContextPrompt();
    
    setState(() {
      _messages.add({
        'role': 'user',
        'text': contextPrompt,
        'image': null,
      });
      _isTyping = true;
    });

    _scrollToBottom();

    // Generate title
    if (_chatTitle == null) {
      _chatTitle = 'Disease Consultation';
    }

    final app = AppLocalizations.of(context);
    String reply;
    try {
      reply = await AIService().sendPrompt(contextPrompt);
    } catch (e) {
      reply = "⚠️ ${app.chatError}: $e";
    }

    if (!mounted) return;

    setState(() {
      _messages.add({'role': 'ai', 'text': reply});
      _isTyping = false;
    });

    _scrollToBottom();
    _saveConversation();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = pickedFile);
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

    // Generate title from first message if not set
    if (_chatTitle == null && text.isNotEmpty) {
      _chatTitle = _historyService.generateTitle(text);
    }

    final app = AppLocalizations.of(context);
    String reply;
    try {
      if (_selectedImage != null) {
        reply = await AIService().sendImage(_selectedImage!);
      } else {
        reply = await AIService().sendPrompt(text);
      }
    } catch (e) {
      reply = "⚠️ ${app.chatError}: $e";
    }

    if (!mounted) return;

    setState(() {
      _messages.add({'role': 'ai', 'text': reply});
      _isTyping = false;
    });

    _scrollToBottom();
    
    // Save conversation to history
    _saveConversation();
  }

  Future<void> _saveConversation() async {
    if (_messages.isEmpty) return;
    
    final chatMessages = _messages.map((m) => ChatMessage(
      role: m['role']!,
      text: m['text'] ?? '',
      imagePath: m['image'],
    )).toList();

    final history = ChatHistory(
      id: _chatId!,
      title: _chatTitle ?? 'New Chat',
      createdAt: widget.history?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      messages: chatMessages,
    );

    await _historyService.saveHistory(history);
  }

  @override
  void dispose() {
    _saveConversation();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final app = AppLocalizations.of(context);
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
                    child: platformImage(
                      _selectedImage!.path,
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
                      hintText: app.askHint,
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
                  child: platformImage(imagePath, fit: BoxFit.contain),
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
    final app = AppLocalizations.of(context);
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
                  onPressed: () {
                    _saveConversation();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _chatTitle ?? app.aiAssistant,
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.white),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatHistoryScreen(),
                      ),
                    );
                    // Reload if history was opened
                    if (widget.history != null && mounted) {
                      // Could reload history here if needed
                    }
                  },
                  tooltip: app.chatHistoryTooltip,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Simple background; removed missing asset to avoid runtime crash
          Container(),
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
