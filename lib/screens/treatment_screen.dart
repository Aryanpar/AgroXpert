// lib/screens/treatment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_localizations.dart';

class TreatmentScreen extends StatelessWidget {
  final String diseaseName;
  final String treatments;
  final double? confidence;
  final String? plant;

  const TreatmentScreen({
    super.key,
    required this.diseaseName,
    required this.treatments,
    this.confidence,
    this.plant,
  });

  static const Color kPrimaryGreen = Color(0xFF2E7D32);
  static const Color kSoftGreenBg = Color(0xFFF1FAF3);

  Map<String, String> _splitIntoSections(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    String overview = '';
    final prevention = <String>[];
    final treatment = <String>[];

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (overview.isEmpty && (lower.startsWith('overview') || !line.startsWith('-'))) {
        if (lower.startsWith('overview')) {
          overview = line.replaceFirst(RegExp(r'(?i)overview:?\s*'), '');
          continue;
        }
        if (overview.isEmpty) {
          overview = line;
          continue;
        }
      }
      if (lower.startsWith('-') || lower.startsWith('prevention')) {
        if (lower.startsWith('prevention')) continue;
        prevention.add(line.replaceFirst(RegExp(r'^\-\s*'), ''));
        continue;
      }
      if (line.startsWith('-')) {
        treatment.add(line.replaceFirst(RegExp(r'^\-\s*'), ''));
      } else {
        treatment.add(line);
      }
    }

    return {
      'overview': overview,
      'prevention': prevention.join('\n'),
      'treatment': treatment.join('\n'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final app = AppLocalizations.of(context);
    final sections = _splitIntoSections(treatments);
    return Scaffold(
      appBar: AppBar(title: Text(diseaseName), centerTitle: true, backgroundColor: kPrimaryGreen),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(diseaseName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (plant != null && plant!.isNotEmpty) Row(children: [const Icon(Icons.local_florist, color: kPrimaryGreen), const SizedBox(width: 8), Flexible(child: Text('${app.plant}: $plant'))]),
                  if (confidence != null) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [const Icon(Icons.check_circle, color: kPrimaryGreen), const SizedBox(width: 8), Text('${app.confidence}: ${(confidence! * 100).toStringAsFixed(1)}%')])),
                ]),
              ),
              Column(children: [
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: treatments));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.planCopied)));
                  },
                  icon: const Icon(Icons.copy, color: Colors.black87),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.shareNotImplemented)));
                  },
                  icon: const Icon(Icons.share, color: kPrimaryGreen),
                ),
              ]),
            ]),

            const SizedBox(height: 12),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: kSoftGreenBg, borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (sections['overview'] != null && sections['overview']!.isNotEmpty) ...[
                      Text(app.overview, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(sections['overview']!, style: const TextStyle(height: 1.4)),
                      const SizedBox(height: 12),
                    ],
                    if (sections['prevention'] != null && sections['prevention']!.isNotEmpty) ...[
                      Text(app.prevention, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(sections['prevention']!, style: const TextStyle(height: 1.4)),
                      const SizedBox(height: 12),
                    ],
                    if (sections['treatment'] != null && sections['treatment']!.isNotEmpty) ...[
                      Text(app.treatment, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(sections['treatment']!, style: const TextStyle(height: 1.4)),
                    ],
                    if ((sections['overview'] ?? '').isEmpty && (sections['prevention'] ?? '').isEmpty && (sections['treatment'] ?? '').isEmpty)
                      Text(treatments.isEmpty ? app.noTreatmentDetails : treatments),
                  ]),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: treatments));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.planCopied)));
                  },
                  icon: const Icon(Icons.copy, color: Colors.black87),
                    label: Text(app.copyPlan, style: const TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: Text(app.close, style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
