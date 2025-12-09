import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  
  const SocialButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}