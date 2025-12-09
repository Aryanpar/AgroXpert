import 'package:flutter/material.dart';

class LanguageOption extends StatelessWidget {
  final String language;
  final VoidCallback onTap;
  
  const LanguageOption({
    super.key,
    required this.language,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          language,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
        onTap: onTap,
      ),
    );
  }
}