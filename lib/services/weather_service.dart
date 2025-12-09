import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherService {
  static const String _apiKey = "24912e79f66ef5ed607da1e3f8f3f7b9";
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  static const String _forecastUrl = "https://api.openweathermap.org/data/2.5/forecast";

  static Future<Weather> getWeather(double lat, double lon) async {
    final url = Uri.parse("$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception("Failed to fetch weather: ${response.statusCode} ${response.body}");
    }
  }
  
  static Future<List<Map<String, dynamic>>> getForecast(double lat, double lon) async {
    final url = Uri.parse("$_forecastUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&cnt=32");
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['list'];
      
      // Group by day and get one forecast per day
      Map<String, Map<String, dynamic>> dailyForecasts = {};
      
      for (var item in list) {
        final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final day = "${date.year}-${date.month}-${date.day}";
        
        // Only keep one forecast per day (noon forecast preferred)
        if (!dailyForecasts.containsKey(day) || 
            (date.hour >= 11 && date.hour <= 14)) {
          dailyForecasts[day] = {
            'date': date,
            'temp': item['main']['temp'],
            'main': item['weather'][0]['main'],
            'description': item['weather'][0]['description'],
          };
        }
      }
      
      // Convert to list and sort by date
      List<Map<String, dynamic>> result = dailyForecasts.values.toList();
      result.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      
      // Limit to next 4 days
      return result.take(4).toList();
    } else {
      throw Exception("Failed to fetch forecast: ${response.statusCode} ${response.body}");
    }
  }
}
