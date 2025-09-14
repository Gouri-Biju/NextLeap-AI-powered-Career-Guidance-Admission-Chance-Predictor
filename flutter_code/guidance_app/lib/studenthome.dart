import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:guidance_app/admission_prediction.dart';
import 'package:guidance_app/chatbotml.dart';
import 'package:guidance_app/complaint.dart';
import 'package:guidance_app/learn.dart';
import 'package:guidance_app/login.dart';
import 'package:guidance_app/pstudent.dart';
import 'package:guidance_app/scollege.dart';
import 'package:guidance_app/sprofile.dart';
import 'package:guidance_app/ssuggestion.dart';
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
  int? uid;
  String? u;
  String? baseUrl; // Replace with backend URL
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBaseUrl();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }
  Future<void> _loadBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = prefs.getString('url') ?? "http://default-url.com";
      // default value if nothing is saved
    });
  }

  Future<void> _loadUserData() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      userImage = sh.getString('uimg');
      u=sh.getString('uid');
      uid=int.parse(u.toString());
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
              size: Size(80, MediaQuery.of(context).size.height),
              painter: VerticalSvgWavePainter(isLeft: true),
            ),
          ),

          // Right Wave
          Align(
            alignment: Alignment.centerRight,
            child: CustomPaint(
              size: Size(80, MediaQuery.of(context).size.height),
              painter: VerticalSvgWavePainter(isLeft: false),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Logout Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white), // white icon
                      onPressed: () async {
                        final sh = await SharedPreferences.getInstance();
                        await sh.clear(); // clear saved user data
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

                // Profile Avatar
                FadeTransition(
                  opacity: _controller,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00695C), Color(0xFF26A69A)], // teal
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF5D4037).withOpacity(0.25), // dark brown glow
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
                          userImage!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.person,
                            size: 60, color: Color(0xFF5D4037)), // dark brown icon
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
                          color: Color(0xFF3E2723), // deep brown text
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Your AI Career Companion Awaits",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF26A69A), // teal accent
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
                        _buildCard(Icons.person_outline, "Profile",
                            const Color(0xFF10B981), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StudentProfileApp()),
                              );
                            }),

                        _buildCard(Icons.android, "ChatBot",
                            const Color(0xFF2563EB), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatBotPage(userId: uid!)),
                              );
                            }),
                        _buildCard(Icons.local_library, "Colleges",
                            const Color(0xFF06B6D4), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StudentCollegeApp()),
                              );
                            }),
                        _buildCard(Icons.bar_chart_outlined, "Admission Prediction",
                            const Color(0xFF2563EB), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdmissionPredictionPage(title: 'prediction')),
                              );
                            }),
                        _buildCard(Icons.message_outlined, "Complaints",
                            const Color(0xFF2563EB), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ComplaintApp()),
                              );
                            }),




                        _buildCard(Icons.logout,
                            "Logout", const Color(0xFF6366F1), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginApp()),
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
            colors: [Colors.white, Color(0xFFF5F5F5)], // soft background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D4037).withOpacity(0.15), // dark brown
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
            Icon(icon, size: 36, color: const Color(0xFF5D4037)), // dark brown
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723), // deep brown text
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for vertical waves
class VerticalSvgWavePainter extends CustomPainter {
  final bool isLeft;
  VerticalSvgWavePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF3D405B), // existing bluish shade
          const Color(0xFF5D4037), // added dark brown
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    Path path = Path();

    if (isLeft) {
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(size.width * 0.3, size.height * 0.2,
          size.width, size.height * 0.4);
      path.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
          size.width, size.height * 0.8);
      path.quadraticBezierTo(size.width * 0.3, size.height * 0.9,
          size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.2,
          0, size.height * 0.4);
      path.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
          0, size.height * 0.8);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.9,
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
