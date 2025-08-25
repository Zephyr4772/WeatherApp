import 'dart:async';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_provider.dart';
import '../widgets/email_signup_overlay.dart';
import '../widgets/forecast_card.dart';

class WeatherScreen extends StatefulWidget {
  final Color backgroundColor;
  const WeatherScreen({super.key, required this.backgroundColor});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _signupTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _startSignupTimer();
  }

  Future<void> _startSignupTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSignedUp = prefs.getBool('hasSignedUp') ?? false;

    if (!hasSignedUp) {
      _signupTimer = Timer(const Duration(seconds: 60), () {
        _showEmailSignupDialog();
      });
    }
  }

  // --- MODIFIED: Pass the background color to the overlay ---
  void _showEmailSignupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmailSignupOverlay(themeColor: widget.backgroundColor),
    );
  }
  // --- END MODIFICATION ---

  @override
  void dispose() {
    _controller.dispose();
    _signupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.backgroundColor, widget.backgroundColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.black),
                        onPressed: () => Navigator.pushNamed(context, '/splash'),
                      ),
                      actions: const [],
                    ),
                    Expanded(
                      child: Consumer<WeatherProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(child: CircularProgressIndicator(color: Colors.black));
                          }
                          if (provider.errorMessage != null) {
                            return Center(
                                child: Text(provider.errorMessage!,
                                    style: GoogleFonts.inter(color: Colors.red, fontSize: 18),
                                    textAlign: TextAlign.center));
                          }
                          if (provider.weatherData == null) {
                            return Center(
                                child: Text('Something went wrong.',
                                    style: GoogleFonts.inter(color: Colors.black, fontSize: 18)));
                          }

                          final weather = provider.weatherData!;
                          final forecast = provider.forecastData;

                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weather.cityName,
                                  style: GoogleFonts.ledger(fontSize: 48, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                                  style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${weather.temperature.round()}°C',
                                        style: GoogleFonts.ledger(fontSize: 120, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        weather.condition,
                                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildSectionTitle('Daily Summary'),
                                Text(
                                  'Now it feels like ${weather.feelsLike.round()}°. It\'s ${weather.condition.toLowerCase()} with a high of ${weather.tempMax.round()}° and a low of ${weather.tempMin.round()}°.',
                                  style: GoogleFonts.inter(fontSize: 16, color: Colors.black87, height: 1.5),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildExtraDetail(Icons.air, '${weather.windSpeed} km/h', 'Wind', widget.backgroundColor),
                                      _buildExtraDetail(Icons.water_drop_outlined, '${weather.humidity}%', 'Humidity', widget.backgroundColor),
                                      _buildExtraDetail(Icons.visibility_outlined, '${(weather.visibility / 1000).toStringAsFixed(1)} km', 'Visibility', widget.backgroundColor),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildSectionTitle('Weekly Forecast'),
                                if (forecast != null)
                                  SizedBox(
                                    height: 140,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: forecast.length,
                                      itemBuilder: (context, index) {
                                        return ForecastCard(forecast: forecast[index]);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.ledger(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExtraDetail(IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
      ],
    );
  }
}
