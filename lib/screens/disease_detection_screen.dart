import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';
import '../services/ai_service.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final TFLiteService _tfliteService = TFLiteService();
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _prediction;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    setState(() => _isLoading = true);
    try {
      await _tfliteService.loadModel();
    } catch (e) {
      setState(() => _error = 'Failed to load model: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _prediction = null;
        _error = null;
      });

      await _detectDisease(_image!);
    } catch (e) {
      setState(() => _error = 'Failed to pick image: $e');
    }
  }

  Future<void> _detectDisease(File image) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _prediction = null; // Reset prediction when starting new detection
    });

    try {
      final result = await _tfliteService.runInference(image);

      if (mounted) {
        setState(() {
          if (result.containsKey('error')) {
            _error = result['error'];
          } else if (result.isEmpty ||
              (!result.containsKey('label') &&
                  !result.containsKey('allPredictions') &&
                  !result.containsKey('topPredictions'))) {
            _error = 'No valid predictions found';
          } else {
            _prediction = result;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error during detection: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _image == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_search,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No image selected',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Loading Indicator
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing image...'),
                ],
              ),

            // Error Message
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red[800]),
                  textAlign: TextAlign.center,
                ),
              ),
            // Prediction Result
            if (_prediction != null) _buildPredictionResult(),
          ],
        ),
      ),
    );
  }

  // Method to get solution from Groq API
  Future<String> _getSolution(String diseaseName) async {
    final aiService = AIService();
    final prompt =
        "Give a compact, actionable plan for '$diseaseName'.\n"
        "Use plain text only (no Markdown or special characters).\n"
        "Structure:\n"
        "Overview: 1 short sentence.\n"
        "Prevention: 3–5 short lines starting with '-'.\n"
        "Treatment: 3–5 short lines starting with '-'.\n"
        "Keep each line under 12 words.\n"
        "Add a brief safety note if chemicals are used.";

    try {
      final solution = await aiService.sendPrompt(prompt);
      final cleaned = _refineSolution(solution);
      if (_looksLikeError(solution) || cleaned.isEmpty) {
        return _fallbackPlan(diseaseName);
      }
      return cleaned;
    } catch (e) {
      return _fallbackPlan(diseaseName);
    }
  }

  /// Remove Markdown markers and tidy spacing for a cleaner look
  String _refineSolution(String raw) {
    var s = raw.trim();
    // Strip common markdown markers
    s = s.replaceAll('**', '');
    s = s.replaceAll('*', '');
    s = s.replaceAll('_', '');
    s = s.replaceAll('`', '');
    // Remove verbose section titles that make it look like AI output
    final reHeading = RegExp(
      r'^(solution|disease overview|prevention methods|treatment options|integrated management|chemical treatment schedule)\s*:?\s*$',
      caseSensitive: false,
      multiLine: true,
    );
    s = s.replaceAll(reHeading, '');
    // Normalize numbered lists and bullet characters to simple dashes
    s = s.replaceAll(RegExp(r'(?m)^\s*\d+[\.)]\s*'), '- ');
    s = s.replaceAll(RegExp(r'(?m)^\s*[•\-]\s*'), '- ');
    // Convert any stray bullets in the middle of lines
    s = s.replaceAll('•', '- ');
    // Remove leading/trailing whitespace per line
    s = s.split('\n').map((l) => l.trim()).join('\n');
    // Collapse multiple blank lines
    s = s.replaceAll(RegExp(r"\n{3,}"), "\n\n");
    // Remove excessive spaces
    s = s.replaceAll(RegExp(r"[ ]{2,}"), " ");
    // Keep the plan concise: limit total lines
    final lines = s.split('\n');
    if (lines.length > 12) {
      s = lines.take(12).join('\n');
    }
    return s;
  }

  /// Detect common error markers from network/API responses
  bool _looksLikeError(String s) {
    final lower = s.toLowerCase();
    return s.startsWith('⚠') ||
        lower.contains('api key not set') ||
        lower.contains('error') ||
        lower.contains('network') ||
        lower.contains('invalid') ||
        lower.contains('unauthorized') ||
        lower.contains('forbidden');
  }

  /// Fallback compact plan when the online call fails
  String _fallbackPlan(String diseaseName) {
    final name = diseaseName.isEmpty ? 'this disease' : diseaseName;
    return [
      '- Remove infected leaves and debris.',
      '- Avoid overhead irrigation; use drip if possible.',
      '- Improve airflow; prune crowded areas.',
      '- Clean tools after use to reduce spread.',
      '- If allowed, apply copper-based fungicide per label.',
      'Safety: Follow local guidelines and wear protection.',
    ].join('\n');
  }

  Widget _buildPredictionResult() {
    // Check if we have valid predictions
    if (_prediction == null ||
        (!_prediction!.containsKey('label') &&
            !_prediction!.containsKey('allPredictions') &&
            !_prediction!.containsKey('topPredictions'))) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: const Text(
          'No valid predictions',
          style: TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    final diseaseName = _prediction!['label']?.toString() ?? 'Unknown';

    // Get all predictions if available
    List<dynamic> allPredictions = [];
    if (_prediction!.containsKey('allPredictions')) {
      allPredictions = _prediction!['allPredictions'] as List<dynamic>;
    } else if (_prediction!.containsKey('topPredictions')) {
      allPredictions = _prediction!['topPredictions'] as List<dynamic>;
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Result',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Top result: $diseaseName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          // Show solution for the detected disease
          const SizedBox(height: 16),
          const Text(
            'Treatment plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _getSolution(diseaseName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Subtle placeholder instead of spinner to avoid "API call" feel
                return const Text(
                  'Preparing plan…',
                  style: TextStyle(color: Colors.grey),
                );
              } else if (snapshot.hasError) {
                return const Text(
                  'Plan unavailable.',
                  style: TextStyle(color: Colors.red),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    snapshot.data ?? 'No solution available.',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }
            },
          ),

          // Hide processing time to avoid revealing backend calls
        ],
      ),
    );
  }
}
