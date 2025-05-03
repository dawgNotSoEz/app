import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // In a real app, you would use your own API key
  // For demo purposes, we'll simulate the API response
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with actual API key in production
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData?> getWeatherForLocation(String location) async {
    try {
      // For demo purposes, we'll return simulated data
      // In a real app, you would make an actual API call
      if (_apiKey == 'YOUR_API_KEY') {
        return _getSimulatedWeatherData(location);
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl?q=$location&appid=$_apiKey&units=metric'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        debugPrint('Error fetching weather: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception fetching weather: $e');
      return _getSimulatedWeatherData(location);
    }
  }

  // Simulated data for demo purposes
  WeatherData? _getSimulatedWeatherData(String location) {
    // Return different weather based on location to simulate real data
    switch (location.toLowerCase()) {
      case 'spain':
      case 'tarifa':
        return WeatherData(
          temperature: 22,
          windSpeed: 25,
          windDirection: 'NE',
          description: 'Partly cloudy',
          icon: 'partly_cloudy',
        );
      case 'hawaii':
      case 'maui':
        return WeatherData(
          temperature: 27,
          windSpeed: 30,
          windDirection: 'E',
          description: 'Sunny',
          icon: 'sunny',
        );
      case 'caribbean':
      case 'bonaire':
        return WeatherData(
          temperature: 29,
          windSpeed: 18,
          windDirection: 'SE',
          description: 'Clear sky',
          icon: 'clear',
        );
      case 'brazil':
      case 'jericoacoara':
        return WeatherData(
          temperature: 31,
          windSpeed: 22,
          windDirection: 'E',
          description: 'Sunny',
          icon: 'sunny',
        );
      case 'france':
      case 'leucate':
        return WeatherData(
          temperature: 19,
          windSpeed: 28,
          windDirection: 'NW',
          description: 'Cloudy',
          icon: 'cloudy',
        );
      default:
        return WeatherData(
          temperature: 24,
          windSpeed: 20,
          windDirection: 'N',
          description: 'Partly cloudy',
          icon: 'partly_cloudy',
        );
    }
  }
}

class WeatherData {
  final double temperature;
  final double windSpeed;
  final String windDirection;
  final String description;
  final String icon;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.description,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDirection: _getWindDirection(json['wind']['deg']),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }

  static String _getWindDirection(num degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees % 360) / 45).round() % 8;
    return directions[index];
  }

  // Get appropriate weather icon
  IconData getWeatherIcon() {
    switch (icon) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'partly_cloudy':
        return Icons.wb_cloudy;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.grain;
      default:
        return Icons.wb_sunny;
    }
  }
}
