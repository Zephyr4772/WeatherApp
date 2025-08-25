import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherService({required this.apiKey});

  Future<Weather> getCurrentWeatherByCityName(String cityName) async {
    final url = '$_baseUrl/weather?q=$cityName&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather for $cityName. City not found.');
    }
  }

  Future<List<Weather>> getFiveDayForecastByCityName(String cityName) async {
    final url = '$_baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric';
    return _handleForecastResponse(url, cityName);
  }

  Future<Weather> getCurrentWeatherByLocation(double lat, double lon) async {
    final url = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data. Status code: ${response.statusCode}');
    }
  }

  Future<List<Weather>> getFiveDayForecastByLocation(double lat, double lon) async {
    final url = '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    final cityName = json.decode(response.body)['city']['name'];
    return _handleForecastResponse(url, cityName);
  }

  Future<List<Weather>> _handleForecastResponse(String url, String cityName) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['list'];

      final List<Weather> dailyForecasts = [];
      final Set<int> days = {};

      for (var item in list) {
        final forecastDate = DateTime.parse(item['dt_txt']);
        if (!days.contains(forecastDate.day) && dailyForecasts.length < 5) {
          dailyForecasts.add(Weather.fromForecastJson(item, cityName));
          days.add(forecastDate.day);
        }
      }
      return dailyForecasts;

    } else {
      throw Exception('Failed to load forecast data. Status code: ${response.statusCode}');
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }

    if (permission == LocationPermission.deniedForever) return Future.error('Location permissions are permanently denied.');

    return await Geolocator.getCurrentPosition();
  }
}
