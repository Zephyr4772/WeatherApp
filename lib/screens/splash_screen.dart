import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _uiController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _uiController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _uiController, curve: Curves.easeOut),
    );

    _uiController.forward();
  }

  @override
  void dispose() {
    _gridController.dispose();
    _uiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) {
              return CustomPaint(
                painter: GridPainter(_gridController.value),
                child: Container(),
              );
            },
          ),
          SafeArea(
            child: Stack(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: Colors.black.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        // --- FIX: This now correctly closes the screen ---
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        // --- END FIX ---
                        icon: const Icon(Icons.arrow_back, size: 20),
                        label: Text(
                          'Back to App',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'HueCast',
                            style: GoogleFonts.ledger(
                              fontSize: 48,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Meet The Maker',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialButton(
                                icon: FontAwesomeIcons.instagram,
                                url: 'https://www.instagram.com/zephyr_4772/',
                              ),
                              SizedBox(width: 20),
                              SocialButton(
                                icon: FontAwesomeIcons.github,
                                url: 'https://github.com/Zephyr4772',
                              ),
                              SizedBox(width: 20),
                              SocialButton(
                                icon: FontAwesomeIcons.linkedinIn,
                                url: 'https://www.linkedin.com/in/sinhal-joshi-244603275?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SocialButton extends StatefulWidget {
  final IconData icon;
  final String url;

  const SocialButton({super.key, required this.icon, required this.url});

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _isHovered = false;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.1 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.grey.shade300.withOpacity(0.7)
              : Colors.grey.shade200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
        ),
        child: IconButton(
          icon: FaIcon(widget.icon, color: Colors.blue.shade800, size: 28),
          onPressed: () => _launchURL(widget.url),
          tooltip: widget.url.split('/')[2],
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double animationValue;
  final double gridSize = 50.0;

  GridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final gridPaint = Paint()
      ..color = Colors.blue.shade800.withOpacity(0.3)
      ..strokeWidth = 1.0;

    final double offsetX = (animationValue * gridSize) % gridSize;
    final double offsetY = (animationValue * gridSize) % gridSize;

    for (double x = -offsetX; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = -offsetY; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
