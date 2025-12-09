import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_localizations.dart';
import '../utils/language_provider.dart';
import 'login.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;
  final List<String> _languages = ['English', 'हिन्दी', 'ગુજરાતી', 'मराठी'];

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations(const Locale('en'));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appLocalizations.chooseLanguage,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.pleaseSelect,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // Language options dynamically built
            ..._languages.map((lang) => _buildLanguageOption(lang)).toList(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedLanguage == null
                  ? null
                  : () {
                      // Set the selected language in the provider
                      Provider.of<LanguageProvider>(context, listen: false)
                          .setLocale(_selectedLanguage!);
                          
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            selectedLanguage: _selectedLanguage!,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                appLocalizations.next,
                style: TextStyle(
                  color: _selectedLanguage == null ? Colors.grey[600] : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          language,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
          size: 16,
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
        ),
        onTap: () {
          setState(() {
            _selectedLanguage = language;
          });
        },
      ),
    );
  }
}
