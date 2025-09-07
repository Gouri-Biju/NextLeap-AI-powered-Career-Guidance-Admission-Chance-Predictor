import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:guidance_app/complaint.dart';
import 'package:guidance_app/pstudent.dart';
import 'package:guidance_app/sprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Career Guidance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const StudentPage(title: 'AI Career Dashboard'),
    );
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key, required this.title});
  final String title;

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage>
    with SingleTickerProviderStateMixin {
  String? userImage;
  String baseUrl = "http://yourserver.com"; // Replace with backend URL
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  Future<void> _loadUserData() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      userImage = sh.getString('uimg');
    });
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
              size: Size(90, MediaQuery.of(context).size.height),
              painter: VerticalSvgWavePainter(isLeft: true),
            ),
          ),

          // Right Wave
          Align(
            alignment: Alignment.centerRight,
            child: CustomPaint(
              size: Size(90, MediaQuery.of(context).size.height),
              painter: VerticalSvgWavePainter(isLeft: false),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 25),

                // Profile Avatar
                FadeTransition(
                  opacity: _controller,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: userImage != null
                            ? Image.network(
                          "$baseUrl/static/media/$userImage",
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.person,
                            size: 60, color: Colors.black54),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Welcome Text
                FadeTransition(
                  opacity: _controller,
                  child: Column(
                    children: const [
                      Text(
                        "Hello, Future Achiever 👩‍🎓",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Your AI Career Companion Awaits",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // Dashboard Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      children: [
                        _buildCard(Icons.message_outlined, "Complaints",
                            const Color(0xFF2563EB), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ComplaintApp()),
                              );
                            }),
                        _buildCard(Icons.person_outline, "Profile",
                            const Color(0xFF10B981), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StudentProfileApp()),
                              );
                            }),
                        _buildCard(Icons.school_outlined, "Attend Test",
                            const Color(0xFF3B82F6), () {}),
                        _buildCard(Icons.lightbulb_outline, "Suggestions",
                            const Color(0xFF06B6D4), () {}),
                        _buildCard(Icons.bar_chart_outlined,
                            "Admission Prediction", const Color(0xFF6366F1), () {}),
                        _buildCard(Icons.work_outline, "Job Recommendation",
                            const Color(0xFF059669), () {}),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for different vertical waves on each side
class VerticalSvgWavePainter extends CustomPainter {
  final bool isLeft;
  VerticalSvgWavePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF3D405B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    Path path = Path();

    if (isLeft) {
      // More curvy left wave
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(size.width * 0.2, size.height * 0.15,
          size.width, size.height * 0.35);
      path.quadraticBezierTo(size.width * 0.4, size.height * 0.55,
          size.width, size.height * 0.7);
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.9,
          size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
      path.close();
    } else {
      // Smoother right wave
      path.moveTo(0, 0);
      path.quadraticBezierTo(size.width * 0.8, size.height * 0.25,
          0, size.height * 0.45);
      path.quadraticBezierTo(size.width * 0.6, size.height * 0.65,
          0, size.height * 0.85);
      path.quadraticBezierTo(size.width * 0.9, size.height * 0.95,
          0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
