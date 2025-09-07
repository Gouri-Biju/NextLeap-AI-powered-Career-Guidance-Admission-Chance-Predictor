import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:guidance_app/login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ParentRegApp extends StatefulWidget {
  const ParentRegApp({super.key});

  @override
  State<ParentRegApp> createState() => _ParentRegAppState();
}

class _ParentRegAppState extends State<ParentRegApp>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String? selectedStudentName;
  String? selectedStudentId;
  List<dynamic> students = [];
  File? _pickedPDF;
  String? _pdfFileName;

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
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _placeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // Fetch students
  Future<void> fetchStudents() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? urlp = sh.getString('url');
    if (urlp == null) return;
    try {
      var url = Uri.parse("$urlp/get_students/");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            students = data['students'];
            students.sort((a, b) =>
                a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
          });
        }
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  // Student selection popup
  void showStudentPopup() {
    TextEditingController searchController = TextEditingController();
    List<dynamic> filteredStudents = List.from(students);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Select Student"),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search by name",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          filteredStudents = students
                              .where((student) => student['name']
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredStudents.isEmpty
                          ? const Center(child: Text("No students found"))
                          : ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: FutureBuilder<SharedPreferences>(
                              future: SharedPreferences.getInstance(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircleAvatar(
                                      child: Icon(Icons.person));
                                }
                                String baseUrl =
                                    snapshot.data!.getString('url') ?? '';
                                return CircleAvatar(
                                  backgroundImage:
                                  filteredStudents[index]['photo'] !=
                                      ''
                                      ? NetworkImage(
                                      "$baseUrl/static/media/${filteredStudents[index]['photo']}")
                                      : null,
                                  child: filteredStudents[index]
                                  ['photo'] ==
                                      ''
                                      ? const Icon(Icons.person)
                                      : null,
                                );
                              },
                            ),
                            title: Text(filteredStudents[index]['name']),
                            subtitle:
                            Text(filteredStudents[index]['place']),
                            onTap: () {
                              setState(() {
                                selectedStudentId =
                                    filteredStudents[index]['id']
                                        .toString();
                                selectedStudentName =
                                filteredStudents[index]['name'];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Pick Image
  Future<void> pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedPDF = File(result.files.single.path!);
          _pdfFileName = result.files.single.name;
        });
      }
    } catch (e) {
      print("Error picking PDF: $e");
    }
  }


  // Submit Parent Registration
  Future<void> registerParent() async {
    // Validation
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String place = _placeController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String pincode = _pincodeController.text.trim();

    // Check required fields
    if (username.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        place.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        pincode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    // Name validation
    if (!RegExp(r"^[A-Za-z ]+$").hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name should contain only letters")),
      );
      return;
    }

    // Password validation
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$')
        .hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Password must be 8+ chars with upper, lower, digit, and special character")),
      );
      return;
    }

    // Email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email address")),
      );
      return;
    }

    // Phone validation
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number must be 10 digits")),
      );
      return;
    }

    // Pincode validation
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pincode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pincode must be 6 digits")),
      );
      return;
    }

    // Student check
    if (selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a student")),
      );
      return;
    }

    // Proof image check
    if (_pickedPDF == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload proof PDF")),
      );
      return;
    }


    // If all validations pass → continue registration
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? urlp = sh.getString('url');
    if (urlp == null) return;

    var uri = Uri.parse("$urlp/preg/");
    var request = http.MultipartRequest('POST', uri);

    request.fields['uname'] = username;
    request.fields['pwd'] = password;
    request.fields['name'] = name;
    request.fields['place'] = place;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['pincode'] = pincode;
    request.fields['sid'] = selectedStudentId!;

    request.files.add(await http.MultipartFile.fromPath('proof_pdf', _pickedPDF!.path));


    var response = await request.send();
    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      var data = json.decode(respStr);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginApp()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text("Registration Failed: ${data['message'] ?? ''}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error in Registration")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: ModernWavePainter(progress: _waveController.value),
                child: Container(),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF8B1E3F), Color(0xFF2C3145)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(Icons.family_restroom,
                                    size: 55, color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Parent Registration",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: "Name",
                                  prefixIcon:
                                  Icon(Icons.badge, color: Color(0xFF8B1E3F)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _placeController,
                                decoration: const InputDecoration(
                                  labelText: "Place",
                                  prefixIcon: Icon(Icons.location_city,
                                      color: Color(0xFF8B1E3F)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  prefixIcon:
                                  Icon(Icons.email, color: Color(0xFF8B1E3F)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: "Phone",
                                  prefixIcon:
                                  Icon(Icons.phone, color: Color(0xFF8B1E3F)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _pincodeController,
                                decoration: const InputDecoration(
                                  labelText: "Pincode",
                                  prefixIcon: Icon(Icons.pin,
                                      color: Color(0xFF8B1E3F)),
                                ),
                              ),
                              const SizedBox(height: 28),
                              TextField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: "Username",
                                  prefixIcon: Icon(Icons.person,
                                      color: Color(0xFF8B1E3F)),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: "Password",
                                  prefixIcon:
                                  Icon(Icons.lock, color: Color(0xFF8B1E3F)),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 22),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B1E3F),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                ),
                                onPressed: showStudentPopup,
                                child: Text(
                                  selectedStudentName ?? "Select Student",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C3145),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                ),
                                onPressed: pickPDF,
                                child: const Text(
                                  "Upload Proof",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),

                              if (_pdfFileName != null)
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "Selected File: $_pdfFileName",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B1E3F),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                  ),
                                  onPressed: registerParent,
                                  child: const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  // Replace with your login page navigation
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginApp(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Already Registered? Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
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

// Dummy Login Page placeholder
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Login Page (Replace with actual login UI)"),
      ),
    );
  }
}

/// Reuse wave painter from Login template
class ModernWavePainter extends CustomPainter {
  final double progress;
  ModernWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF2C3145), Color(0xFF3D405B), Color(0xFF8B1E3F)],
      stops: [0.0, 0.7, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint backgroundPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

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
