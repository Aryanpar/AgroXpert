import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  File? _imageFile;
  bool _isUpdating = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      await _updateProfilePhoto();
    }
  }

  Future<void> _updateProfilePhoto() async {
    if (_imageFile == null || user == null) return;

    setState(() => _isUpdating = true);

    try {
      // 1. Upload file to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_photos")
          .child("${user!.uid}.jpg");

      await storageRef.putFile(_imageFile!);

      // 2. Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // 3. Update Firebase user profile with the new URL
      await user!.updatePhotoURL(downloadUrl);

      // 4. Reload the user to refresh data
      await user!.reload();

      setState(() {
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated!")),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating photo: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final updatedUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar with Edit button
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (updatedUser?.photoURL != null
                            ? NetworkImage(updatedUser!.photoURL!)
                            : null) as ImageProvider<Object>?,
                    child: (updatedUser?.photoURL == null && _imageFile == null)
                        ? Text(
                            (updatedUser?.displayName != null &&
                                    updatedUser!.displayName!.isNotEmpty)
                                ? updatedUser.displayName![0].toUpperCase()
                                : "U",
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green.shade600,
                        child: _isUpdating
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : const Icon(Icons.camera_alt,
                                size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // User Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileRow(
                        icon: Icons.person,
                        title: "Name",
                        value: updatedUser?.displayName ?? "Not set"),
                    const Divider(),
                    _buildProfileRow(
                        icon: Icons.email,
                        title: "Email",
                        value: updatedUser?.email ?? "Not available"),
                    const Divider(),
                    _buildProfileRow(
                        icon: Icons.perm_identity,
                        title: "UID",
                        value: updatedUser?.uid ?? "Unknown",
                        valueStyle: const TextStyle(
                            fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Edit profile coming soon")),
                    );
                  },
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                    side: BorderSide(color: Colors.green.shade600, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String title,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              Text(value,
                  style: valueStyle ??
                      const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
