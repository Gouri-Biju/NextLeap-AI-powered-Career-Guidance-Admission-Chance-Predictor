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
      title: 'AI Career Guidance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF8B1E3F), // Maroon accent for label
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
      home: const MyHomePage(title: 'AI Career Guidance'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  final _ipformkey = GlobalKey<FormState>();
  final TextEditingController _ipcontroller = TextEditingController();

  late final AnimationController _waveController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _ipcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with bluish ash dominant gradient
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: ModernWavePainter(progress: _waveController.value),
                child: Container(),
              );
            },
          ),

          // Glass Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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

                              // Title
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Enter your server IP address to continue",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 28),

                              // Form
                              Form(
                                key: _ipformkey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _ipcontroller,
                                      keyboardType: TextInputType.url,
                                      decoration: const InputDecoration(
                                        labelText:
                                        "IP Address (e.g. 192.168.1.12:8002)",
                                        prefixIcon: Icon(
                                          Icons.cloud_outlined,
                                          color: Color(0xFF8B1E3F),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "IP Address is required";
                                        }
                                        final ipPortRegex = RegExp(
                                            r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?::\d{1,5})?$');
                                        if (!ipPortRegex.hasMatch(value)) {
                                          return "Enter a valid IP (e.g. 192.168.1.12:8002)";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 28),

                                    // Themed Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFF8B1E3F), // Maroon
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          elevation: 8,
                                        ),
                                        onPressed: () async {
                                          if (_ipformkey.currentState!
                                              .validate()) {
                                            SharedPreferences sh =
                                            await SharedPreferences
                                                .getInstance();
                                            String url = _ipcontroller.text;
                                            sh.setString('url', 'http://$url');
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const LoginApp()),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          "Continue",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        ],
      ),
    );
  }
}

/// Bluish ash dominant Wave Painter
class ModernWavePainter extends CustomPainter {
  final double progress;
  ModernWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = const LinearGradient(
      colors: [
        Color(0xFF2C3145), // Primary bluish ash
        Color(0xFF3D405B), // Secondary ash
        Color(0xFF8B1E3F), // Maroon accent
      ],
      stops: [0.0, 0.7, 1.0], // 70% ash, 30% maroon
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint backgroundPaint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // Animated wave
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
