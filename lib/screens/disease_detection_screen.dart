// lib/screens/disease_detection_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_service.dart';
import '../services/tflite_service.dart';
import 'treatment_screen.dart';
import '../utils/app_localizations.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen>
    with SingleTickerProviderStateMixin {
  final TFLiteService _tfliteService = TFLiteService();
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _prediction;
  String? _error;

  late final AnimationController _btnController;
  final ImagePicker _picker = ImagePicker();

  // Theme constants
  static const Color kPrimaryGreen = Color(0xFF2E7D32);
  static const Color kAccentGreen = Color(0xFF66BB6A);
  static const Color kSoftGreenBg = Color(0xFFF1FAF3);

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    setState(() => _isLoading = true);
    try {
      await _tfliteService.loadModel();
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load model: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 88, maxWidth: 1600, maxHeight: 1600);
      if (picked == null) return;
      final file = File(picked.path);
      setState(() {
        _image = file;
        _prediction = null;
        _error = null;
      });
      _btnController.forward(from: 0.0);
      await _detectDisease(file);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to pick image: $e');
    }
  }

  Future<void> _detectDisease(File image) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _prediction = null;
    });

    try {
      final raw = await _tfliteService.runInference(image);
      if (!mounted) return;
      final parsed = _parseInferenceResult(raw);
      if (parsed == null) {
        setState(() => _error = 'No valid predictions found');
      } else {
        setState(() => _prediction = parsed);
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) await _showResultModal(parsed, image);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Error during detection: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? _parseInferenceResult(dynamic raw) {
    try {
      if (raw == null) return null;
      if (raw is Map<String, dynamic>) {
        if (raw.containsKey('label')) {
          final label = raw['label']?.toString() ?? 'Unknown';
          final conf = _coerceConfidence(raw['confidence'] ?? raw['score'] ?? raw['probability']);
          final plant = (raw['plant'] ?? raw['plant_name'])?.toString();
          final preds = _extractPredictions(raw);
          return {'label': label, 'confidence': conf, 'plant': plant, 'predictions': preds};
        }
        if (raw.containsKey('allPredictions') || raw.containsKey('topPredictions') || raw.containsKey('predictions')) {
          final list = (raw['allPredictions'] ?? raw['topPredictions'] ?? raw['predictions']) as List<dynamic>;
          final preds = _normalizePredictionList(list);
          if (preds.isEmpty) return null;
          return {'label': preds.first['label'], 'confidence': preds.first['confidence'], 'plant': raw['plant']?.toString(), 'predictions': preds};
        }
      } else if (raw is List) {
        final preds = _normalizePredictionList(raw);
        if (preds.isEmpty) return null;
        return {'label': preds.first['label'], 'confidence': preds.first['confidence'], 'plant': null, 'predictions': preds};
      } else if (raw is String) {
        return {'label': raw, 'confidence': 1.0, 'plant': null, 'predictions': [{'label': raw, 'confidence': 1.0}]};
      }
    } catch (_) {}
    return null;
  }

  double _coerceConfidence(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v.clamp(0.0, 1.0);
    if (v is int) return (v / 100.0).clamp(0.0, 1.0);
    final parsed = double.tryParse(v.toString());
    if (parsed != null) return (parsed > 1 ? (parsed / 100.0) : parsed).clamp(0.0, 1.0);
    return 0.0;
  }

  List<Map<String, dynamic>> _normalizePredictionList(List<dynamic> raw) {
    final out = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item == null) continue;
      if (item is String) {
        out.add({'label': item, 'confidence': 1.0});
      } else if (item is Map) {
        final label = (item['label'] ?? item['name'] ?? item['disease'] ?? item['class'])?.toString();
        final conf = _coerceConfidence(item['confidence'] ?? item['probability'] ?? item['score']);
        if (label != null) out.add({'label': label, 'confidence': conf});
      } else if (item is num) {
        out.add({'label': item.toString(), 'confidence': _coerceConfidence(item)});
      } else {
        out.add({'label': item.toString(), 'confidence': 0.0});
      }
    }
    out.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    return out;
  }

  List<Map<String, dynamic>> _extractPredictions(Map<String, dynamic> raw) {
    if (raw.containsKey('predictions') && raw['predictions'] is List) return _normalizePredictionList(raw['predictions'] as List<dynamic>);
    if (raw.containsKey('allPredictions') && raw['allPredictions'] is List) return _normalizePredictionList(raw['allPredictions'] as List<dynamic>);
    if (raw.containsKey('topPredictions') && raw['topPredictions'] is List) return _normalizePredictionList(raw['topPredictions'] as List<dynamic>);
    return [];
  }

  Future<void> _showResultModal(Map<String, dynamic> parsed, File image) async {
    final label = parsed['label']?.toString() ?? 'Unknown';
    final confidence = (parsed['confidence'] as double?) ?? 0.0;
    final plant = parsed['plant']?.toString();
    final app = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          top: false,
          child: DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.28,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18)],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: ListView(
                  controller: controller,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 12),

                    // header: image + label + meta
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(image, width: 96, height: 96, fit: BoxFit.cover)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.check_circle, size: 16, color: kAccentGreen),
                              const SizedBox(width: 8),
                              Text('${app.confidence}: ${(confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.black54)),
                            ]),
                            if (plant != null && plant.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('${app.plant}: $plant', style: const TextStyle(color: Colors.black54)),
                            ],
                          ]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // treatment preview
                    Text(app.recommendedAction, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: _getSolution(label),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Column(children: [const LinearProgressIndicator(), const SizedBox(height: 10), Text(app.preparingPlan, style: const TextStyle(color: Colors.black54))]);
                        }
                        if (snap.hasError) return Text(app.planUnavailable, style: const TextStyle(color: Colors.red));
                        final text = snap.data ?? '-';
                        return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kSoftGreenBg, borderRadius: BorderRadius.circular(10)), child: Text(text, style: const TextStyle(color: Colors.black87)));
                      },
                    ),

                    const SizedBox(height: 16),

                    // actions: copy/close
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: label));
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.problemCopied)));
                          },
                          icon: const Icon(Icons.copy, color: Colors.black87),
                          label: Text(app.copyProblem, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6FDE74), padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: Text(app.close, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // open full treatment (fetch then navigate)
                    ElevatedButton(
                      onPressed: () async {
                        final plan = await _getSolution(label);
                        if (!mounted) return;
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TreatmentScreen(
                          diseaseName: label,
                          treatments: plan,
                          confidence: confidence,
                          plant: plant,
                        )));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text(app.openFullTreatment, style: const TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<String> _getSolution(String diseaseName) async {
    final aiService = AIService();
    final prompt =
        "Give a compact, actionable plan for '$diseaseName'.\nOverview: 1 short sentence.\nPrevention: 2–4 short lines starting with '-'.\nTreatment: 2–4 short lines starting with '-'.\nKeep lines short and avoid crop examples.";
    try {
      final sol = await aiService.sendPrompt(prompt);
      final cleaned = _refineSolution(sol);
      return cleaned.isEmpty ? _fallbackPlan(diseaseName) : cleaned;
    } catch (_) {
      return _fallbackPlan(diseaseName);
    }
  }

  String _refineSolution(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'[*`_]'), '');
    s = s.replaceAll(RegExp(r'[•–—]'), '-');
    final lines = s.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return '';
    return lines.take(12).join('\n');
  }

  String _fallbackPlan(String diseaseName) {
    return 'Overview: Remove infected parts and improve airflow.\n- Remove infected leaves and debris.\n- Avoid overhead irrigation; prefer drip.\n- Clean tools after use.';
  }

  Widget _buildPredictionResult() {
    if (_prediction == null) return const SizedBox.shrink();
    final disease = _prediction!['label']?.toString() ?? 'Unknown';
    final plant = _prediction!['plant']?.toString();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kSoftGreenBg, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context).result, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kPrimaryGreen)),
        const SizedBox(height: 8),
        Text('${AppLocalizations.of(context).topResult}: $disease', style: const TextStyle(fontWeight: FontWeight.bold)),
        if (plant != null && plant.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [const Icon(Icons.local_florist, size: 16), const SizedBox(width: 8), Text('${AppLocalizations.of(context).plant}: $plant')])
        ],
      ]),
    );
  }

  @override
  void dispose() {
    _btnController.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppLocalizations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(app.plantCareDetector), centerTitle: true, backgroundColor: kPrimaryGreen),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Align(alignment: Alignment.centerLeft, child: Text(app.detectSubtitle, style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                child: _image == null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.eco, size: 72, color: kPrimaryGreen), const SizedBox(height: 10), Text(app.noImageSelected, style: const TextStyle(color: Colors.black54))]))
                    : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity)),
              ),
            ),

            const SizedBox(height: 14),

            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  label: Text(app.camera, style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, color: Colors.black87),
                  label: Text(app.gallery, style: const TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ]),

            const SizedBox(height: 10),

            if (_isLoading) Row(children: [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 12), Text(app.analyzing)]),

            if (_error != null) Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.error_outline, color: Colors.redAccent), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))])),

            const SizedBox(height: 8),

            if (_prediction != null)
              ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.36), child: SingleChildScrollView(child: _buildPredictionResult())),
          ]),
        ),
      ),
    );
  }
}
