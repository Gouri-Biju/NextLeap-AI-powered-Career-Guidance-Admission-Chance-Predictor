import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guidance_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextLeap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF8B1E3F),
            fontWeight: FontWeight.w600,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF8B1E3F), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  @override
  void initState() {
    super.initState();
    _setUrlAndNavigate();
  }

  Future<void> _setUrlAndNavigate() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    await sh.setString(
      "url",
      "http://192.168.29.230:8002",
    );

    // Wait 5 seconds then go to Login page
    await Future.delayed(const Duration(seconds: 5));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginApp()),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient + wave
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: ModernWavePainter(progress: _waveController.value),
                child: Container(),
              );
            },
          ),

          // Glassmorphic Card
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _fadeController,
                    curve: Curves.easeOut,
                  )),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B1E3F), Color(0xFF2C3145)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.school,
                                  size: 55, color: Colors.white),
                            ),
                            const SizedBox(height: 22),

                            // App Name
                            const Text(
                              "NextLeap",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),

                            // Subtext
                            const Text(
                              "AI-powered Career Guidance &\nAdmission Chance Predictor",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient + Wave Background Painter
class ModernWavePainter extends CustomPainter {
  final double progress;
  ModernWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = const LinearGradient(
      colors: [
        Color(0xFF2C3145),
        Color(0xFF3D405B),
        Color(0xFF8B1E3F),
      ],
      stops: [0.0, 0.7, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint backgroundPaint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // Wave
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    Path path = Path();
    double waveHeight = 30;
    double speed = progress * 2 * pi;

    path.moveTo(0, size.height * 0.55);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
          i,
          size.height * 0.55 +
              waveHeight * sin((i / size.width * 2 * pi) + speed));
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant ModernWavePainter oldDelegate) => true;
}
