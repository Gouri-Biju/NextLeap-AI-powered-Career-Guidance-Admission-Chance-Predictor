import 'package:flutter/material.dart';
import 'package:guidance_app/parenthome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ParentStudentApp());
}

class ParentStudentApp extends StatelessWidget {
  const ParentStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Details',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF800000), // Maroon color
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const ParentStudentPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ParentStudentPage extends StatefulWidget {
  const ParentStudentPage({super.key});

  @override
  State<ParentStudentPage> createState() => _ParentStudentPageState();
}

class _ParentStudentPageState extends State<ParentStudentPage> {
  Map<String, dynamic>? studentData;
  String? baseUrl;

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString('url');
    String? uid = sh.getString('uid'); // Parent ID

    var response = await http.post(
      Uri.parse('$baseUrl/api/pstudent/'),
      body: {'uid': uid},
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result['status'] == 'success' && result['data'].isNotEmpty) {
        setState(() {
          studentData = result['data'][0];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF800000))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Student Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ParentHome()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF800000).withOpacity(0.2),
                child: ClipOval(
                  child: studentData!['image'] != null &&
                      studentData!['image'].toString().isNotEmpty
                      ? Image.network(
                    "$baseUrl/static/media/${studentData!['image']}",
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card with details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.person, "Name", studentData!['name']),
                    _buildDetailRow(Icons.wc, "Gender", studentData!['gender']),
                    _buildDetailRow(Icons.location_city, "Place", studentData!['place']),
                    _buildDetailRow(Icons.home, "Post", studentData!['post']),
                    _buildDetailRow(Icons.pin, "Pin", studentData!['pin'].toString()),
                    _buildDetailRow(Icons.phone, "Phone", studentData!['phone'].toString()),
                    _buildDetailRow(Icons.email, "Email", studentData!['email']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF800000)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF800000),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
