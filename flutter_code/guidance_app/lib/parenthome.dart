import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:guidance_app/admission_prediction.dart';
import 'package:guidance_app/login.dart';
import 'package:guidance_app/particles.dart';
import 'package:guidance_app/pcollege.dart';
import 'package:guidance_app/pcourse.dart';
import 'package:guidance_app/pprofile.dart';
import 'package:guidance_app/pstudent.dart';
import 'package:guidance_app/psuggestion.dart';

void main() {
  runApp(const ParentHome());
}

class ParentHome extends StatelessWidget {
  const ParentHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const ParentHomePage(title: 'Parent Dashboard'),
    );
  }
}

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key, required this.title});
  final String title;

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Left Wave
          Align(
            alignment: Alignment.centerLeft,
            child: CustomPaint(
              size: Size(80, MediaQuery.of(context).size.height),
              painter: VerticalSvgWavePainter(isLeft: true), // original painter
            ),
          ),

          // Right Wave
          Align(
            alignment: Alignment.centerRight,
            child: CustomPaint(
              size: Size(80, MediaQuery.of(context).size.height),
              painter: VerticalSvgWavePainter(isLeft: false), // original painter
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white), // white icon
                      onPressed: () async {
 // clear saved user data
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginApp(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Welcome Banner
                FadeTransition(
                  opacity: _controller,
                  child: Column(
                    children: const [
                      Icon(Icons.family_restroom,
                          size: 70, color: Color(0xFF26A69A)),
                      SizedBox(height: 15),
                      Text(
                        "Welcome, Parent 👨‍👩‍👧‍👦",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Guide Your Child’s Bright Future",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF26A69A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // Dashboard Grid with all Parent Module cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      children: [
                        _buildCard(Icons.person_outline, "View Profile",
                            const Color(0xFF5D4037), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ParentProfileApp()),
                              );
                            }),
                        _buildCard(Icons.school_outlined, "View Student Details",
                            const Color(0xFF06B6D4), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ParentStudentApp()),
                              );
                            }),
                        _buildCard(Icons.menu_book_outlined, "View Course Details",
                            const Color(0xFF6366F1), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ParentCoursePage()),
                              );
                            }),
                        _buildCard(Icons.article_outlined, "Articles",
                            const Color(0xFF06B6D4), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ParticleApp()),
                              );
                            }),
                        _buildCard(Icons.lightbulb_outline, "Colleges",
                            const Color(0xFF059669), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ParentCollegeApp()),
                              );
                              // TODO: Add navigation
                            }),

                        _buildCard(Icons.bar_chart_outlined,
                            "Admission Prediction", const Color(0xFF8B5CF6), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdmissionPredictionPage(title: 'Prediction')),
                              );
                            }),

                      ],
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

  Widget _buildCard(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D4037).withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF5D4037)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Original Wave Painter (kept unchanged)
class VerticalSvgWavePainter extends CustomPainter {
  final bool isLeft;
  VerticalSvgWavePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF3D405B),
          const Color(0xFF5D4037),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    Path path = Path();

    if (isLeft) {
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(
          size.width * 0.3, size.height * 0.2, size.width, size.height * 0.4);
      path.quadraticBezierTo(
          size.width * 0.5, size.height * 0.6, size.width, size.height * 0.8);
      path.quadraticBezierTo(
          size.width * 0.3, size.height * 0.9, size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.quadraticBezierTo(
          size.width * 0.7, size.height * 0.2, 0, size.height * 0.4);
      path.quadraticBezierTo(
          size.width * 0.5, size.height * 0.6, 0, size.height * 0.8);
      path.quadraticBezierTo(
          size.width * 0.7, size.height * 0.9, 0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
