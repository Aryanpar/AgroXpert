import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import 'dashboard.dart';

class IDVerificationScreen extends StatelessWidget {
  const IDVerificationScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ID Verification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Upload a photo of your\nNational ID Card',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Regulations require you to upload a national identity card. Don\'t worry, your data will stay safe and private.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildUploadOption('Select file', Icons.folder_open),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'or',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildUploadOption('Open Camera & Take Photo', Icons.camera_alt),
            const Spacer(),
            CustomButton(
              text: 'Continue',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUploadOption(String text, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, color: Colors.grey.shade700),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
        onTap: () {},
      ),
    );
  }
}