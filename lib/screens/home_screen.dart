import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_provider.dart';
import '../widgets/location_error_overlay.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Color> _colors = const [
    Color(0xFFFFE142),
    Color(0xFF42C6FF),
    Color(0xFFFF64D4),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeatherAndNavigate();
    });
  }

  Future<void> _fetchWeatherAndNavigate() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    await weatherProvider.fetchWeatherForCurrentUserLocation();

    if (mounted && weatherProvider.weatherData != null) {
      final randomColor = _colors[Random().nextInt(_colors.length)];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherScreen(backgroundColor: randomColor),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Consumer<WeatherProvider>(
          builder: (context, provider, child) {
            // If it's an initial launch error, show the animated overlay
            if (provider.isInitialLaunchError) {
              return LocationErrorOverlay(
                errorMessage: provider.errorMessage ?? 'Could not fetch location.',
                onRetry: _fetchWeatherAndNavigate,
              );
            }

            // Otherwise, show the loading indicator
            if (provider.isLoading) {
              return const CircularProgressIndicator(color: Colors.white);
            }

            // This part should ideally not be reached if navigation is successful,
            // but it's a good fallback.
            return const CircularProgressIndicator(color: Colors.white);
          },
        ),
      ),
    );
  }
}
