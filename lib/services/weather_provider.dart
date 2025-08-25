import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_service.dart';
import '../models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService(apiKey: '01b8005b76c85fcec8e7100c922b18ac');

  Weather? _weatherData;
  List<Weather>? _forecastData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialLaunchError = false;

  Weather? get weatherData => _weatherData;
  List<Weather>? get forecastData => _forecastData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialLaunchError => _isInitialLaunchError;

  Future<void> _saveLastCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCity', cityName);
  }

  Future<void> fetchWeatherByCityName(String cityName) async {
    _isLoading = true;
    _errorMessage = null;
    _isInitialLaunchError = false;
    notifyListeners();

    try {
      final weather = await _weatherService.getCurrentWeatherByCityName(cityName);
      final forecast = await _weatherService.getFiveDayForecastByCityName(cityName);
      _weatherData = weather;
      _forecastData = forecast;
      await _saveLastCity(cityName);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherForCurrentUserLocation() async {
    _isLoading = true;
    _errorMessage = null;
    _isInitialLaunchError = false;
    notifyListeners();

    try {
      Position position = await _weatherService.determinePosition();
      final weather = await _weatherService.getCurrentWeatherByLocation(position.latitude, position.longitude);
      final forecast = await _weatherService.getFiveDayForecastByLocation(position.latitude, position.longitude);
      _weatherData = weather;
      _forecastData = forecast;
      await _saveLastCity(weather.cityName);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final lastCity = prefs.getString('lastCity');

      if (lastCity != null) {
        await fetchWeatherByCityName(lastCity);
      } else {
        _errorMessage = e.toString();
        _isInitialLaunchError = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    if (_weatherData != null) {
      _errorMessage = null;
      notifyListeners();
      try {
        final weather = await _weatherService.getCurrentWeatherByCityName(_weatherData!.cityName);
        final forecast = await _weatherService.getFiveDayForecastByCityName(_weatherData!.cityName);
        _weatherData = weather;
        _forecastData = forecast;
      } catch (e) {
        _errorMessage = e.toString();
      } finally {
        notifyListeners();
      }
    }
  }
}
