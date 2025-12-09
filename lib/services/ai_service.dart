// lib/services/ai_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? 'YOUR_GROQ_API_KEY';
  final String _chatUrl = 'https://api.groq.com/openai/v1/chat/completions';

  /// Send text prompt to Groq's API
  Future<String> sendPrompt(String userPrompt) async {
    return _sendMessage(userPrompt);
  }

  /// Send an image file to AI for analysis
  Future<String> sendImage(File imageFile) async {
    return sendPromptWithImage(prompt: 'Analyze this image and give a detailed response.', imageFile: imageFile);
  }

  /// Send both text and an image to the AI
  Future<String> sendPromptWithImage({required String prompt, required File imageFile}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final messages = [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": prompt},
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
            }
          ]
        }
      ];

      return _sendMessage(prompt, messages: messages, model: 'meta-llama/llama-4-scout-17b-16e-instruct');
    } catch (e) {
      return "⚠️ Failed to process image: $e";
    }
  }

  /// Private helper to send messages to the Groq API
  Future<String> _sendMessage(String userPrompt, {List<Map<String, dynamic>>? messages, String model = 'llama-3.3-70b-versatile'}) async {
    if (_apiKey == 'YOUR_GROQ_API_KEY') {
      return "⚠️ API Key not set. Please add your Groq API key to the .env file.";
    }

    try {
      final body = {
        "model": model,
        "messages": messages ?? [
          {"role": "system", "content": "You are a helpful agricultural assistant."},
          {"role": "user", "content": userPrompt}
        ],
        "max_tokens": 400,
        "temperature": 0.6,
      };

      final response = await http.post(
        Uri.parse(_chatUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.toString().trim() ?? "No response.";
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "⚠️ Network or API Error: $e";
    }
  }
}
