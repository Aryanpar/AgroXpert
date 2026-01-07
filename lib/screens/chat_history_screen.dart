// lib/screens/chat_history_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/chat_history.dart';
import '../services/chat_history_service.dart';
import 'chat_ai_screen.dart';
import '../utils/app_localizations.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ChatHistoryService _historyService = ChatHistoryService();
  List<ChatHistory> _histories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() => _isLoading = true);
    final histories = await _historyService.getAllHistories();
    setState(() {
      _histories = histories;
      _isLoading = false;
    });
  }

  Future<void> _deleteHistory(ChatHistory history) async {
    final app = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(app.deleteChat),
        content: Text('${app.deleteChat}: "${history.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(app.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(app.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.deleteHistory(history.id);
      _loadHistories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(app.deleteChat)),
        );
      }
    }
  }

  Future<void> _backupAllChats() async {
    final app = AppLocalizations.of(context);
    try {
      final file = await _historyService.exportToFile();
      if (file != null && mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'AgroXpert Chat Backup',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(app.backupAll)),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(app.chatError)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteAllChats() async {
    final app = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(app.deleteAll),
        content: Text(app.deleteAll),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(app.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(app.deleteAll),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.deleteAllHistories();
      _loadHistories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(app.deleteAll)),
        );
      }
    }
  }

  void _openChat(ChatHistory history) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatAIScreen(history: history),
      ),
    ).then((_) => _loadHistories());
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
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
                Expanded(
                  child: Text(
                    app.chatHistory,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_histories.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'backup') {
                        _backupAllChats();
                      } else if (value == 'delete_all') {
                        _deleteAllChats();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'backup',
                        child: Row(
                          children: [
                            const Icon(Icons.backup, color: Color(0xFF4CAF50), size: 20),
                            const SizedBox(width: 12),
                            Text(app.backupAll, style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete_all',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                            const SizedBox(width: 12),
                            Text(app.deleteAll, style: GoogleFonts.poppins(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        app.chatHistory,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app.askHint,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistories,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _histories.length,
                    itemBuilder: (context, index) {
                      final history = _histories[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF4CAF50),
                            child: const Icon(Icons.chat, color: Colors.white),
                          ),
                          title: Text(
                            history.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                history.previewText,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(history.updatedAt),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteHistory(history);
                              } else if (value == 'backup') {
                                _backupSingleChat(history);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'backup',
                                child: Row(
                                  children: [
                                    const Icon(Icons.backup, size: 20, color: Color(0xFF4CAF50)),
                                    const SizedBox(width: 12),
                                    Text(app.backup, style: GoogleFonts.poppins()),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete, color: Colors.red, size: 20),
                                    const SizedBox(width: 12),
                                    Text(app.delete, style: GoogleFonts.poppins(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _openChat(history),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _backupSingleChat(ChatHistory history) async {
    final app = AppLocalizations.of(context);
    try {
      final jsonData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'histories': [history.toJson()],
      };
      
      final directory = await path_provider.getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chat_${history.id}_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(jsonData));
      
      if (mounted) {
        await Share.shareXFiles([XFile(file.path)]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(app.backup)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${app.chatError}: $e')),
        );
      }
    }
  }
}

