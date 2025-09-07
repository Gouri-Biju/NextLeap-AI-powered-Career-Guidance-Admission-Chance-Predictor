import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ParentCoursePage extends StatefulWidget {
  const ParentCoursePage({super.key});

  @override
  State<ParentCoursePage> createState() => _ParentCoursePageState();
}

class _ParentCoursePageState extends State<ParentCoursePage> {
  Map<String, dynamic>? courseData;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? uid = sh.getString('uid');
    if (url == null || uid == null) return;

    var response = await http.post(
      Uri.parse('$url/api/pcourse/'),
      body: {'uid': uid},
    );

    var result = json.decode(response.body);
    setState(() {
      if (result['data'] != null && result['data'].isNotEmpty) {
        courseData = result['data'][0];
      }
    });
  }

  Widget _buildCourseCard() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.school, color: Color(0xFF8B1E3F), size: 60),
            ),
            const SizedBox(height: 20),
            Text("Course:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 5),
            Text(courseData!['cn'],
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),

            const Divider(height: 25, thickness: 1.2, color: Color(0xFFBDBDBD)),

            Text("Department:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 5),
            Text(courseData!['d'],
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),

            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.confirmation_number_outlined,
                    size: 18, color: Colors.brown.shade700),
                const SizedBox(width: 6),
                Text("ID: ${courseData!['id']}",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.brown.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CustomPaint(
              size: Size(80, MediaQuery.of(context).size.height),
              painter: VerticalSvgWavePainter(isLeft: true),
            ),
          ),
          Positioned(
            right: 20,
            top: 100,
            child: Icon(Icons.menu_book,
                size: 100, color: Color(0xFF8B1E3F).withOpacity(0.12)),
          ),
          Positioned(
            right: 40,
            bottom: 200,
            child: Icon(Icons.school_outlined,
                size: 90, color: Color(0xFF5D4037).withOpacity(0.12)),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF8B1E3F), size: 26),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text("Student Course",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B1E3F))),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: courseData == null
                      ? const Center(
                      child: Text("No course details found.",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)))
                      : SingleChildScrollView(child: _buildCourseCard()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalSvgWavePainter extends CustomPainter {
  final bool isLeft;
  VerticalSvgWavePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF3D405B), Color(0xFF5D4037)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    Path path = Path();
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
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
