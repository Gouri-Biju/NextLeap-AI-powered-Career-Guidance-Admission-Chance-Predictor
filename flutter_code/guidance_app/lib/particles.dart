import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guidance_app/parenthome.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ParticleApp());
}

class ParticleApp extends StatelessWidget {
  const ParticleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Career Guidance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const ParticlePage(title: 'Articles'),
    );
  }
}

class ParticlePage extends StatefulWidget {
  const ParticlePage({super.key, required this.title});
  final String title;

  @override
  State<ParticlePage> createState() => _ParticlePageState();
}

class _ParticlePageState extends State<ParticlePage> {
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    _loadParticles();
  }

  Future<void> _loadParticles() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? uid = sh.getString('uid');
    if (url == null || uid == null) return;

    var response = await http.post(
      Uri.parse('$url/api/particle/'),
      body: {'uid': uid},
    );
    var result = json.decode(response.body);
    setState(() {
      data = result['data'] ?? [];
    });
  }

  Widget _buildParticleCard(dynamic content) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title:",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(
              content['c'],
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const Divider(height: 20, thickness: 1.2, color: Color(0xFFBDBDBD)),
            Text("Subject:",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(
              content['r'],
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.brown.shade400),
                const SizedBox(width: 5),
                Text(
                  content['d'],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.brown.shade600),
                ),
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
            child: Icon(Icons.science,
                size: 100, color: Color(0xFF8B1E3F).withOpacity(0.12)),
          ),
          Positioned(
            right: 40,
            bottom: 200,
            child: Icon(Icons.book,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ParentHome()),
                        );
                      },
                    ),
                    Text(widget.title,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B1E3F))),
                  ],
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: data.isEmpty
                      ? const Center(
                      child: Text('No particle data available',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)))
                      : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _buildParticleCard(data[index]);
                    },
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
