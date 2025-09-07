import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guidance_app/psuggestion.dart';
import 'package:guidance_app/ssuggestion.dart';
import 'package:guidance_app/studenthome.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const StudentCollegeApp());
}

class StudentCollegeApp extends StatelessWidget {
  const StudentCollegeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Career Guidance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const StudentCollegePage(title: 'Colleges'),
    );
  }
}

class StudentCollegePage extends StatefulWidget {
  const StudentCollegePage({super.key, required this.title});
  final String title;

  @override
  State<StudentCollegePage> createState() => _StudentCollegePageState();
}

class _StudentCollegePageState extends State<StudentCollegePage> {
  final _suggestionFormKey = GlobalKey<FormState>();
  final TextEditingController _sug = TextEditingController();
  final TextEditingController _details = TextEditingController();

  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    _loadComp();
  }

  Future<void> _loadComp() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? uid = sh.getString('uid');
    var response = await http.post(
      Uri.parse('$url/api/viewscollege/'),
      body: {'uid': uid},
    );
    var result = json.decode(response.body);
    setState(() {
      data = result['data'];
    });
  }

  Widget _buildCardComp(dynamic content) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("College Name:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(
              content['n'],
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            Text("Place:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(
              content['p'].toString(),
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            const Divider(height: 20, thickness: 1.2, color: Color(0xFFBDBDBD)),
            Text("Phone",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(
              content['ph'].toString(),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            Text("Email:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(
              content['e'].toString(),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text("Proof:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(
              content['pr'],
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            ElevatedButton(onPressed: () async {
              SharedPreferences sh = await SharedPreferences.getInstance();
              sh.setString('cid',content['id'].toString());
              Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentSuggestionApp()));
            }, child: Text('Suggestions'))
          ],
        ),
      ),
    );
  }

  Future<void> _sendSuggestion() async {
    if (_suggestionFormKey.currentState!.validate()) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? uid = sh.getString('uid');
      await http.post(
        Uri.parse('$url/api/sendsuggestion/'),
        body: {
          'uid': uid,
          'sug': _sug.text.trim(),
          'det': _details.text.trim(),
        },
      );
      _sug.clear();
      _details.clear();
      _loadComp();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suggestion sent successfully!'),
          backgroundColor: Color(0xFF8B1E3F),
        ),
      );
    }
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
            top: 80,
            child: Icon(Icons.school,
                size: 100, color: Color(0xFF8B1E3F).withOpacity(0.12)),
          ),
          Positioned(
            right: 40,
            top: 250,
            child: Icon(Icons.menu_book,
                size: 90, color: Color(0xFF5D4037).withOpacity(0.12)),
          ),
          Positioned(
            right: 30,
            bottom: 200,
            child: Icon(Icons.work_outline,
                size: 85, color: Color(0xFF8B1E3F).withOpacity(0.12)),
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
                              builder: (context) => const StudentApp()),
                        );
                      },
                    ),
                    Text(widget.title,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B1E3F))),
                  ],
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: data.isEmpty
                      ? const Center(
                      child: Text('No Suggestion history yet',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)))
                      : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _buildCardComp(data[index]);
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
