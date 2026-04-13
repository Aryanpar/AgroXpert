import 'package:flutter/material.dart';
import '../services/agro_context_service.dart';
import '../utils/app_localizations.dart';

/// Widget to display smart recommendations based on current conditions
class SmartTipCard extends StatelessWidget {
  final SmartRecommendation recommendation;
  final VoidCallback? onActionTap;

  const SmartTipCard({
    super.key,
    required this.recommendation,
    this.onActionTap,
  });

  Color _getSeverityColor() {
    switch (recommendation.severity) {
      case RecommendationSeverity.success:
        return Colors.green;
      case RecommendationSeverity.info:
        return Colors.blue;
      case RecommendationSeverity.warning:
        return Colors.orange;
      case RecommendationSeverity.critical:
        return Colors.red;
    }
  }

  Color _getSeverityBackgroundColor() {
    switch (recommendation.severity) {
      case RecommendationSeverity.success:
        return Colors.green.shade50;
      case RecommendationSeverity.info:
        return Colors.blue.shade50;
      case RecommendationSeverity.warning:
        return Colors.orange.shade50;
      case RecommendationSeverity.critical:
        return Colors.red.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppLocalizations.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getSeverityColor(), width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getSeverityBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  recommendation.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.smartRecommendation,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation.message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (recommendation.action != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onActionTap,
                icon: const Icon(Icons.power_settings_new, size: 18),
                label: Text('${app.activateMotor} ${recommendation.action!.motorName}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getSeverityColor(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
