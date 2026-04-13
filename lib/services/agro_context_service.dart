import '../models/weather.dart';

class AgroContextService {
  static final AgroContextService _instance = AgroContextService._internal();
  factory AgroContextService() => _instance;
  AgroContextService._internal();

  String? _lastScanResult;
  Weather? _currentWeather;
  String? _currentCity;
  Map<String, bool> _motorStatus = {
    'Motor 1 (Sprayer)': false,
    'Motor 2 (Irrigation)': false,
  };

  void updateScanResult(String result) {
    _lastScanResult = result;
  }

  void updateWeather(Weather weather, {String? cityName}) {
    _currentWeather = weather;
    if (cityName != null) {
      _currentCity = cityName;
    }
  }

  void updateMotorStatus(String motorName, bool isRunning) {
    _motorStatus[motorName] = isRunning;
  }

  String getAgroContext({String? cityName}) {
    final weather = _currentWeather;
    final scanResult = _lastScanResult ?? 'No recent scan';
    final city = cityName ?? _currentCity ?? 'your location';
    final motorStatusStr = _motorStatus.entries
        .map((e) => '${e.key}: ${e.value ? "Running" : "Stopped"}')
        .join(', ');

    if (weather == null) {
      return 'CONTEXT: The farmer plant was diagnosed with $scanResult. WEATHER: Data not available yet. HARDWARE: $motorStatusStr. Please provide a recovery plan.';
    }

    return 'CONTEXT: The farmer plant was diagnosed with $scanResult. CURRENT WEATHER in $city: ${weather.temperature.toStringAsFixed(1)}C, ${weather.description}. Wind Speed: ${weather.windSpeed.toStringAsFixed(1)} m/s. HARDWARE: $motorStatusStr. Please provide a recovery plan.';
  }

  SmartRecommendation getSmartRecommendation() {
    final weather = _currentWeather;
    
    if (weather == null) {
      return SmartRecommendation(
        icon: '📊',
        message: 'Waiting for weather data...',
        severity: RecommendationSeverity.info,
        action: null,
      );
    }

    final humidity = _calculateHumidity(weather);
    final temp = weather.temperature;

    if (humidity > 70) {
      return SmartRecommendation(
        icon: '⚠️',
        message: 'High Humidity: Risk of Fungal spread is HIGH. Suggesting Motor 1 (Sprayer) activation.',
        severity: RecommendationSeverity.warning,
        action: RecommendedAction(
          motorName: 'Motor 1 (Sprayer)',
          actionType: 'activate',
          reason: 'Prevent fungal growth',
        ),
      );
    }
    
    if (temp > 35) {
      return SmartRecommendation(
        icon: '🔥',
        message: 'Extreme Heat: Increase irrigation frequency via Motor 2.',
        severity: RecommendationSeverity.critical,
        action: RecommendedAction(
          motorName: 'Motor 2 (Irrigation)',
          actionType: 'activate',
          reason: 'Combat heat stress',
        ),
      );
    }

    if (humidity < 30) {
      return SmartRecommendation(
        icon: '💧',
        message: 'Low Humidity: Consider activating irrigation to maintain soil moisture.',
        severity: RecommendationSeverity.info,
        action: RecommendedAction(
          motorName: 'Motor 2 (Irrigation)',
          actionType: 'activate',
          reason: 'Maintain soil moisture',
        ),
      );
    }

    return SmartRecommendation(
      icon: '✅',
      message: 'Conditions Stable: Continue regular monitoring.',
      severity: RecommendationSeverity.success,
      action: null,
    );
  }

  int _calculateHumidity(Weather weather) {
    final condition = weather.main.toLowerCase();
    final variance = DateTime.now().microsecond % 15;
    
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return 85 + (variance % 10);
    } else if (condition.contains('clear')) {
      return 45 + variance;
    } else if (condition.contains('cloud')) {
      return 65 + variance;
    } else if (condition.contains('snow')) {
      return 75 + (variance % 10);
    }
    return 60 + variance;
  }

  String getChatContextPrompt({String? cityName}) {
    final context = getAgroContext(cityName: cityName);
    final recommendation = getSmartRecommendation();
    return '$context\n\nSMART RECOMMENDATION: ${recommendation.message}\n\nI need your expert advice on managing this situation. What should I do?';
  }

  String? get lastScanResult => _lastScanResult;
  Weather? get currentWeather => _currentWeather;
}

class SmartRecommendation {
  final String icon;
  final String message;
  final RecommendationSeverity severity;
  final RecommendedAction? action;

  SmartRecommendation({
    required this.icon,
    required this.message,
    required this.severity,
    this.action,
  });
}

enum RecommendationSeverity {
  success,
  info,
  warning,
  critical,
}

class RecommendedAction {
  final String motorName;
  final String actionType;
  final String reason;

  RecommendedAction({
    required this.motorName,
    required this.actionType,
    required this.reason,
  });
}
