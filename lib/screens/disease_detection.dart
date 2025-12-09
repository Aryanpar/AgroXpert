import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/tflite_service.dart';
import 'treatment_screen.dart'; // Import Treatment Screen

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final TFLiteService _tfliteService = TFLiteService();
  File? _selectedImage;
  String? _diseaseResult;
  String? _confidence;
  bool _isLoading = false;
  List<Map<String, dynamic>> _allPredictions = [];

  @override
  void initState() {
    super.initState();
    _loadTFLiteModel();
  }

  bool _modelLoaded = false;

  Future<void> _loadTFLiteModel() async {
    if (_modelLoaded) return;

    setState(() => _isLoading = true);
    try {
      print('Initializing TFLite model...');
      await _tfliteService.loadModel();
      _modelLoaded = true;
      print('TFLite model initialized successfully');
    } catch (e) {
      final errorMsg = "Failed to load disease detection model: $e";
      print(errorMsg);
      if (mounted) {
        _showError(errorMsg);
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _diseaseResult = null;
          _confidence = null;
          _allPredictions = [];
        });
        await _detectDisease();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _detectDisease() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _tfliteService.runInference(_selectedImage!);
      if (result != null && result.isNotEmpty && !result.containsKey('error')) {
        // Get the top prediction
        final disease = result['label'];
        final confidence = result['confidence'];

        // Get all predictions
        final allPredictions = result['allPredictions'] as List<dynamic>;

        setState(() {
          _diseaseResult = disease;
          _confidence = (confidence * 100).toStringAsFixed(2);
          _allPredictions = List<Map<String, dynamic>>.from(allPredictions);
        });

        _showMessage('Detected: $_diseaseResult • $_confidence%');
      } else {
        _showError(
          'Could not detect any disease: ${result['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      _showError('Error detecting disease: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Disease Detection',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Scan a leaf to detect disease',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Camera and Gallery Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Camera',
                      Icons.camera_alt,
                      () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      'Gallery',
                      Icons.photo_library,
                      () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Show selected image preview
              if (_selectedImage != null)
                Center(
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

              // Show detection result
              if (_diseaseResult != null && _confidence != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top result: $_diseaseResult • $_confidence%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'More results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ..._allPredictions.map((prediction) {
                        final label = prediction['label'] as String;
                        final confidence =
                            (prediction['confidence'] as double) * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                '${confidence.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

              const SizedBox(height: 40),
              const Text(
                'Recent scans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildScanItem(
                _diseaseResult ?? 'Cotton Leaf — Healthy',
                '13 Jul, 10:23 AM',
                _confidence ?? '96%',
                Colors.green,
              ),
              const SizedBox(height: 12),

              _buildScanItem(
                'Tomato Leaf — Bacterial Spot',
                '12 Jul, 3:48 PM',
                '89%',
                Colors.orange,
              ),
              const SizedBox(height: 16),

              // Button that navigates to TreatmentScreen
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TreatmentScreen(
                          diseaseName:
                              _diseaseResult ?? 'Tomato Leaf — Bacterial Spot',
                          treatments: [
                            'Apply copper-based fungicide every 7–10 days.',
                            'Avoid overhead irrigation to minimize leaf wetness.',
                            'Remove and destroy infected leaves.',
                          ],
                          precautions:
                              'Ensure proper crop rotation and avoid reusing contaminated soil or equipment.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Treatment',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ), // This closes the SingleChildScrollView
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: const Color(0xFF4CAF50)),
              const SizedBox(height: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanItem(
    String title,
    String date,
    String confidence,
    Color color,
  ) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Icon(Icons.scanner, color: color),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          date,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Text(
          confidence,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
