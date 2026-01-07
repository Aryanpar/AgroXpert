// lib/services/chat_history_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_history.dart';

class ChatHistoryService {
  static const String _historyKey = 'chat_history_list';
  static const int _maxHistoryCount = 50;

  /// Get all chat histories
  Future<List<ChatHistory>> getAllHistories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      
      return historyJson
          .map((json) => ChatHistory.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      return [];
    }
  }

  /// Save a chat history
  Future<void> saveHistory(ChatHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final histories = await getAllHistories();
      
      // Remove existing history with same ID
      histories.removeWhere((h) => h.id == history.id);
      
      // Add updated history
      histories.add(history);
      
      // Limit to max count
      if (histories.length > _maxHistoryCount) {
        histories.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        histories.removeRange(_maxHistoryCount, histories.length);
      }
      
      // Save back
      final historyJson = histories
          .map((h) => jsonEncode(h.toJson()))
          .toList();
      
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  /// Delete a chat history
  Future<void> deleteHistory(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final histories = await getAllHistories();
      histories.removeWhere((h) => h.id == id);
      
      final historyJson = histories
          .map((h) => jsonEncode(h.toJson()))
          .toList();
      
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Error deleting chat history: $e');
    }
  }

  /// Delete all chat histories
  Future<void> deleteAllHistories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Error deleting all histories: $e');
    }
  }

  /// Export all histories to JSON file
  Future<File?> exportToFile() async {
    try {
      final histories = await getAllHistories();
      final jsonData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'histories': histories.map((h) => h.toJson()).toList(),
      };

      final directory = await path_provider.getApplicationDocumentsDirectory();
      final file = File('${directory.path}/agroxpert_chat_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(jsonData));
      
      return file;
    } catch (e) {
      debugPrint('Error exporting chat history: $e');
      return null;
    }
  }

  /// Import histories from JSON file
  Future<bool> importFromFile(File file) async {
    try {
      final content = await file.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      final historiesJson = jsonData['histories'] as List;
      
      for (final historyJson in historiesJson) {
        final history = ChatHistory.fromJson(historyJson as Map<String, dynamic>);
        await saveHistory(history);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error importing chat history: $e');
      return false;
    }
  }

  /// Generate a title from the first user message
  String generateTitle(String firstMessage) {
    if (firstMessage.isEmpty) return 'New Chat';
    final words = firstMessage.trim().split(' ');
    if (words.length <= 5) return firstMessage;
    return '${words.take(5).join(' ')}...';
  }
}

