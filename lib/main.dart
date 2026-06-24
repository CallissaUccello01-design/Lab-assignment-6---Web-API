  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:flutter_dotenv/flutter_dotenv.dart';

  void main() async {
    await dotenv.load(fileName: ".env");
    runApp(const WeatherApp());
  }

  class WeatherApp extends StatelessWidget {
    const WeatherApp({super.key});

    @override
    Widget build(BuildContext context) {
      return const MaterialApp(
        home: WeatherScreen(),
      );
    }
  }

  class WeatherService {
    Future<Map<String, dynamic>> fetchWeather(String city) async {
      final apiKey = dotenv.env['API_KEY'];
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    }
  }

  class WeatherScreen extends StatefulWidget {
    const WeatherScreen({super.key});

    @override
    State<WeatherScreen> createState() => _WeatherScreenState();
  }

  class _WeatherScreenState extends State<WeatherScreen> {
    final TextEditingController cityController = TextEditingController();

   final WeatherService _weatherService = WeatherService();

    bool _isLoading = false;
    Map<String, dynamic> _weatherData = {};
    String _error = "";

    Future<void> _fetchWeather() async {
      setState(() {
        _isLoading = true;
        _error = "";
        _weatherData = {};
      });
      try {
       final data = await _weatherService.fetchWeather(cityController.text);
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = "Could not load weather data.";
          _isLoading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Weather App"),
        ),
        body: ListView(
            children: [
              const Text(
                "Current Weather Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: "Name of the City",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchWeather,
                child: const Text(
                  "Get Weather Information",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator(),
              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_weatherData.isNotEmpty)
                Text(
                 '${_weatherData['main']['temp']}°C',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_weatherData.isNotEmpty)
                Text(
                 '${_weatherData['weather'][0]['description']}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
      );
    }
  }