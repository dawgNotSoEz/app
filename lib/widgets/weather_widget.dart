import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final String locationId;
  final String locationName;

  const WeatherWidget({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _isLoading = true;
  WeatherData? _weatherData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weatherService = Provider.of<WeatherService>(context, listen: false);
      final data = await weatherService.getWeatherForLocation(widget.locationId);
      
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load weather data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weather at ${widget.locationName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isLoading && _errorMessage == null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchWeatherData,
                    tooltip: 'Refresh weather data',
                  ),
              ],
            ),
            const Divider(),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchWeatherData,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  _buildCurrentWeather(),
                  const SizedBox(height: 16),
                  _buildWindInfo(),
                  const SizedBox(height: 16),
                  _buildForecast(),
                ],
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slide(
          begin: const Offset(0, 0.1),
          end: const Offset(0, 0),
          duration: 500.ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildCurrentWeather() {
    if (_weatherData == null) return const SizedBox.shrink();
    
    final currentTemp = _weatherData!.temperature;
    final condition = _weatherData!.description;
    final humidity = 65; // Simulated humidity value as it's not in the WeatherData class
    
    return Row(
      children: [
        _getWeatherIcon(condition),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$currentTemp°C',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                condition,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
              ),
              Text(
                'Humidity: $humidity%',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildWindInfo() {
    if (_weatherData == null) return const SizedBox.shrink();
    
    final windSpeed = _weatherData!.windSpeed;
    final windDirection = _weatherData!.windDirection;
    final windGust = _weatherData!.windSpeed * 1.3; // Simulated gust value as it's not in the WeatherData class
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.withOpacity(0.1)
            : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.blue.withOpacity(0.3)
              : Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wind Conditions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWindInfoItem(
                Icons.speed,
                '$windSpeed km/h',
                'Speed',
              ),
              _buildWindInfoItem(
                Icons.explore,
                windDirection,
                'Direction',
              ),
              _buildWindInfoItem(
                Icons.air,
                '$windGust km/h',
                'Gusts',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildWindInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildForecast() {
    if (_weatherData == null) return const SizedBox.shrink();
    
    // Simulated forecast data as it's not in the WeatherData class
    final forecast = [
      {'day': 'Today', 'condition': _weatherData!.description, 'max': _weatherData!.temperature.round(), 'min': (_weatherData!.temperature - 3).round()},
      {'day': 'Tomorrow', 'condition': 'Partly cloudy', 'max': (_weatherData!.temperature + 1).round(), 'min': (_weatherData!.temperature - 4).round()},
      {'day': 'Wed', 'condition': 'Sunny', 'max': (_weatherData!.temperature + 2).round(), 'min': (_weatherData!.temperature - 2).round()},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3-Day Forecast',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            itemBuilder: (context, index) {
              final day = forecast[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day['day'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _getWeatherIcon(day['condition'] as String, size: 24),
                    const SizedBox(height: 4),
                    Text('${day['max']}°/${day['min']}°'),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms + (index * 100).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _getWeatherIcon(String condition, {double size = 48}) {
    IconData iconData;
    
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        iconData = Icons.wb_sunny;
        break;
      case 'partly cloudy':
      case 'partly_cloudy':
        iconData = Icons.wb_cloudy;
        break;
      case 'cloudy':
        iconData = Icons.cloud;
        break;
      case 'overcast':
        iconData = Icons.cloud;
        break;
      case 'mist':
      case 'fog':
        iconData = Icons.cloud;
        break;
      case 'rain':
      case 'light rain':
      case 'moderate rain':
        iconData = Icons.grain;
        break;
      case 'heavy rain':
        iconData = Icons.thunderstorm;
        break;
      case 'snow':
        iconData = Icons.ac_unit;
        break;
      case 'thunderstorm':
        iconData = Icons.flash_on;
        break;
      default:
        iconData = Icons.wb_sunny;
    }
    
    return Icon(
      iconData,
      size: size,
      color: _getWeatherIconColor(condition),
    );
  }

  Color _getWeatherIconColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.amber;
      case 'partly cloudy':
        return Colors.amber.shade300;
      case 'cloudy':
      case 'overcast':
        return Colors.grey;
      case 'mist':
      case 'fog':
        return Colors.blueGrey;
      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
        return Colors.blue;
      case 'snow':
        return Colors.lightBlue;
      case 'thunderstorm':
        return Colors.deepPurple;
      default:
        return Colors.amber;
    }
  }
}
