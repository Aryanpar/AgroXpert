// lib/widgets/chat_bubble.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final String? imagePath;
  final bool showAvatar;

  const ChatBubble({
    Key? key,
    required this.isUser,
    required this.text,
    this.imagePath,
    this.showAvatar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(16);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left avatar for AI
          if (!isUser && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade600,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 6),
          ],

          // Bubble
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFF3F4F6), Color(0xFFEAF0EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                  bottomLeft: isUser ? radius : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : radius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text first (optional)
                  if (text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: imagePath != null ? 6 : 0),
                      child: _buildTextContent(),
                    ),
                  // Image next (optional)
                  if (imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(imagePath!),
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Right avatar for user
          if (isUser && showAvatar) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade400,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    // Clean up markdown formatting for better display
    final cleanedText = _cleanMarkdown(text);
    
    return Text(
      cleanedText,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: isUser ? Colors.white : Colors.black87,
        height: 1.35,
      ),
    );
  }

  String _cleanMarkdown(String text) {
    // Remove common markdown formatting that shows as stars
    String cleaned = text;
    
    // First, convert list markers at start of lines to bullet points
    cleaned = cleaned.replaceAll(RegExp(r'^[\*\-\+]\s+', multiLine: true), '• ');
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');
    
    // Remove bold markdown (**text**)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove code blocks (```code```)
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    
    // Remove inline code (`code`)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove headers (# Header)
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Remove links [text](url) but keep the text
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove italic markdown (*text*) - only if it's not a bullet point
    // Match *text* where * is not at start of line
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'([^\n\*])\*([^*\n]+)\*([^\n\*])'),
      (match) => '${match.group(1)}${match.group(2)}${match.group(3)}',
    );
    
    // Remove standalone asterisks in the middle of sentences
    cleaned = cleaned.replaceAll(RegExp(r'([^\s\*])\*([^\s\*])'), r'$1 $2');
    
    // Clean up extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    cleaned = cleaned.replaceAll(RegExp(r' {2,}'), ' ');
    cleaned = cleaned.trim();
    
    return cleaned;
  }
}
