import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/social_button.dart';
import 'id_verification.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _signup() async {
    setState(() => isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await credential.user?.updateDisplayName(nameController.text.trim());

      // Navigate to ID Verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IDVerificationScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please log in.';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else {
        message = e.message ?? 'Something went wrong.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'AgroXpert Plus',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildInputField('Name', 'Enter your name', controller: nameController),
            const SizedBox(height: 20),
            _buildInputField('Email', 'Enter your email', controller: emailController),
            const SizedBox(height: 20),
            _buildInputField('Password', 'Create your password', controller: passwordController, isPassword: true),
            const SizedBox(height: 30),
            CustomButton(
              text: isLoading ? 'Signing Up...' : 'Sign Up',
              onPressed: isLoading ? () {} : _signup,
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 24),
            SocialButton(
              text: 'Google',
              icon: Icons.g_mobiledata,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            SocialButton(
              text: 'Facebook',
              icon: Icons.facebook,
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {bool isPassword = false, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
