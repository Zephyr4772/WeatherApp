import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;

  const WeatherIcon({super.key, required this.condition, this.size = 64});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (condition.toLowerCase()) {
      case 'clouds':
        iconData = Icons.cloud_outlined;
        break;
      case 'rain':
        iconData = Icons.grain; // A nice rain icon
        break;
      case 'clear':
        iconData = Icons.wb_sunny_outlined;
        break;
      case 'snow':
        iconData = Icons.ac_unit;
        break;
      case 'thunderstorm':
        iconData = Icons.flash_on;
        break;
      default:
        iconData = Icons.cloud_queue;
    }
    return Icon(iconData, size: size, color: Colors.black);
  }
}
