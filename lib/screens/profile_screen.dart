import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/platform_utils.dart';
import 'package:provider/provider.dart';
import '../utils/language_provider.dart';
import '../utils/app_localizations.dart';
import 'language_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  XFile? _imageFile;
  bool _isUpdating = false;
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingProfile = false;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    final current = FirebaseAuth.instance.currentUser;
    _nameController.text = current?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
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

      await platformUpload(storageRef, _imageFile!);

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

  Future<void> _saveProfileChanges() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return;

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }

    setState(() => _isSavingProfile = true);
    try {
      await current.updateDisplayName(newName);
      await current.reload();

      setState(() {
        _isSavingProfile = false;
        _isEditingProfile = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      setState(() => _isSavingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  Future<void> _sendEmailVerification() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) return;

    try {
      await current.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Verification email sent. Please check your inbox or spam.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending verification email: $e")),
      );
    }
  }

  Future<void> _sendPasswordReset() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null || current.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No email associated with this account")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: current.email!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Password reset email sent to ${current.email}. Please check your inbox.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending password reset email: $e")),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                        ? platformImageProvider(_imageFile!.path)
                        : (updatedUser?.photoURL != null
                            ? NetworkImage(updatedUser!.photoURL!)
                            : null),
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
                    _isEditingProfile
                        ? _buildEditableNameRow()
                        : _buildProfileRow(
                            icon: Icons.person,
                            title: "Name",
                            value: updatedUser?.displayName ?? "Not set",
                          ),
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

            const SizedBox(height: 20),

            // Account actions: email verification & password reset
            _buildAccountActionsCard(updatedUser),

            const SizedBox(height: 20),

            // Language Selection Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageSettingsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.language,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<LanguageProvider>(
                              builder: (context, provider, child) {
                                final appLocalizations = AppLocalizations(provider.currentLocale);
                                return Text(
                                  appLocalizations.language,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Consumer<LanguageProvider>(
                              builder: (context, provider, child) {
                                String currentLang = 'English';
                                switch (provider.currentLocale.languageCode) {
                                  case 'en':
                                    currentLang = 'English';
                                    break;
                                  case 'hi':
                                    currentLang = 'हिन्दी';
                                    break;
                                  case 'gu':
                                    currentLang = 'ગુજરાતી';
                                    break;
                                  case 'mr':
                                    currentLang = 'मराठी';
                                    break;
                                }
                                return Text(
                                  currentLang,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
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
                  label: Text(_isEditingProfile
                      ? (_isSavingProfile ? "Saving..." : "Save")
                      : "Edit"),
                  onPressed: _isSavingProfile
                      ? null
                      : () async {
                          if (_isEditingProfile) {
                            await _saveProfileChanges();
                          } else {
                            setState(() {
                              _isEditingProfile = true;
                              _nameController.text =
                                  updatedUser?.displayName ?? '';
                            });
                          }
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

  Widget _buildEditableNameRow() {
    return Row(
      children: [
        Icon(Icons.person, color: Colors.green.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActionsCard(User? updatedUser) {
    final isVerified = updatedUser?.emailVerified ?? false;
    final email = updatedUser?.email;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                isVerified ? Icons.verified : Icons.mark_email_unread,
                color: isVerified ? Colors.green.shade600 : Colors.orange,
              ),
              title: Text(
                isVerified ? "Email Verified" : "Email Not Verified",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isVerified
                    ? "Your email address is verified."
                    : "Verify your email to secure your account.",
              ),
              trailing: !isVerified && email != null
                  ? TextButton(
                      onPressed: _sendEmailVerification,
                      child: const Text("Verify"),
                    )
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.lock_reset,
                color: Colors.red.shade400,
              ),
              title: const Text(
                "Reset Password",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                email != null
                    ? "Send a password reset link to $email"
                    : "No email linked to this account.",
              ),
              trailing: email != null
                  ? TextButton(
                      onPressed: _sendPasswordReset,
                      child: const Text("Send link"),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
