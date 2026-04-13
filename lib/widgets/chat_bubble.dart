import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/platform_utils.dart';

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
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
                        bottom: imagePath != null ? 6 : 0,
                      ),
                      child: _buildTextContent(context),
                    ),
                  // Image next (optional)
                  if (imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: platformImage(
                        imagePath!,
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

  Widget _buildTextContent(BuildContext context) {
    final textColor = isUser ? Colors.white : Colors.black87;

    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.poppins(
          fontSize: 15,
          color: textColor,
          height: 1.35,
        ),
        strong: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        em: GoogleFonts.poppins(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: textColor,
        ),
        h1: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        h2: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        h3: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        listBullet: GoogleFonts.poppins(color: textColor),
      ),
    );
  }
}
