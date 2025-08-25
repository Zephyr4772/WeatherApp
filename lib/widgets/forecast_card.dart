import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../widgets/weather_icon.dart';

class ForecastCard extends StatelessWidget {
  final Weather forecast;

  const ForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(right: 12),
      child: Blur(
        borderRadius: BorderRadius.circular(20),
        blur: 5,
        blurColor: Colors.white.withOpacity(0.1),
        overlay: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                DateFormat('E').format(forecast.date!), // e.g., 'Mon'
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              WeatherIcon(condition: forecast.condition, size: 32),
              Text(
                '${forecast.temperature.round()}°',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        child: Container(), // Child is for the blur effect
      ),
    );
  }
}
