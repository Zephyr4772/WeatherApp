import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationErrorOverlay extends StatefulWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const LocationErrorOverlay({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<LocationErrorOverlay> createState() => _LocationErrorOverlayState();
}

class _LocationErrorOverlayState extends State<LocationErrorOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.25, end: 0.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: -0.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.25, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _animation,
                child: const Icon(
                  Icons.location_off_rounded,
                  color: Colors.redAccent,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Location Not Found',
                style: GoogleFonts.ledger(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  widget.errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9f5afd),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
