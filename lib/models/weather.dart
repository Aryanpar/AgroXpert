import 'package:flutter/material.dart';

class Weather {
  final double temperature;
  final double feelsLike;
  final String description;
  final double windSpeed;
  final String main;

  Weather({
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.windSpeed,
    required this.main,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      description: json['weather'][0]['description'],
      main: json['weather'][0]['main'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }

  IconData getWeatherIcon() {
    switch (main.toLowerCase()) {
      case 'clouds':
        return Icons.wb_cloudy;
      case 'rain':
        return Icons.grain;
      case 'clear':
        return Icons.wb_sunny;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.wb_cloudy;
    }
  }
}
