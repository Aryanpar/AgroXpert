import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final Map<String, String> _languageMap = {
  'English': 'en',
  'हिन्दी': 'hi',
  'ગુજરાતી': 'gu',
  'मराठी': 'mr',
};


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);
    final appLocalizations = AppLocalizations(provider.currentLocale);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.language,
                  size: 64,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                appLocalizations.chooseLanguage,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                appLocalizations.pleaseSelect,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Language options dynamically built
              Expanded(
                child: ListView.builder(
                  itemCount: _languageMap.length,
                  itemBuilder: (context, index) {
                    final language = _languageMap.keys.elementAt(index);
                    return _buildLanguageOption(language);
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectedLanguage == null
                    ? null
                    : () async {
                        // Set the selected language in the provider
                        await Provider.of<LanguageProvider>(context, listen: false)
                            .setLocale(_selectedLanguage!);
                            
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                selectedLanguage: _selectedLanguage!,
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                  elevation: 2,
                ),
                child: Text(
                  appLocalizations.next,
                  style: GoogleFonts.poppins(
                    color: _selectedLanguage == null ? Colors.grey[600] : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    final flagMap = {
      'English': '🇬🇧',
      'हिन्दी': '🇮🇳',
      'ગુજરાતી': '🇮🇳',
      'मराठी': '🇮🇳',
    };
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedLanguage = language;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Flag/Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      flagMap[language] ?? '🌐',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Language Name
                Expanded(
                  child: Text(
                    language,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.black87,
                    ),
                  ),
                ),
                // Selection Indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey[400],
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
