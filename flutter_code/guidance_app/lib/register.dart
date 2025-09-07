import 'dart:math';
import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guidance_app/login.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RegApp());
}

class RegApp extends StatelessWidget {
  const RegApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration',
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
        ),
      ),
      home: const RegPage(title: 'User Registration'),
    );
  }
}

class RegPage extends StatefulWidget {
  const RegPage({super.key, required this.title});
  final String title;

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> with TickerProviderStateMixin {
  final _regformkey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  String? _gender; // dropdown
  final TextEditingController _place = TextEditingController();
  final TextEditingController _post = TextEditingController();
  final TextEditingController _pin = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _pwd = TextEditingController();

  File? _profileImage;
  bool _imageError = false;

  List<dynamic> _courses = [];
  String? _selectedCourseId;

  late final AnimationController _waveController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      if (url == null) return;

      var response = await http.get(Uri.parse('$url/api/getcourses/'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _courses = data['data'];
          });
        }
      }
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        _imageError = false;
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return "Name is required";
    final nameRegex = RegExp(r'^[A-Za-z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return "Only letters allowed";
    }
    return null;
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) return "Pin code is required";
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return "Enter a valid 6-digit pin";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Phone number is required";
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Enter a valid 10-digit phone";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 8) return "Minimum 8 characters required";
    final upper = RegExp(r'[A-Z]');
    final lower = RegExp(r'[a-z]');
    final digit = RegExp(r'\d');
    final special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!upper.hasMatch(value) ||
        !lower.hasMatch(value) ||
        !digit.hasMatch(value) ||
        !special.hasMatch(value)) {
      return "Include uppercase, lowercase, number & special char";
    }
    return null;
  }

  Future<void> _registerUser() async {
    setState(() {
      _imageError = _profileImage == null;
    });

    if (_regformkey.currentState!.validate() && !_imageError) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      if (url == null) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$url/api/sreg/'),
      );
      request.fields['uname'] = _username.text;
      request.fields['pwd'] = _pwd.text;
      request.fields['name'] = _name.text;
      request.fields['gender'] = _gender!;
      request.fields['place'] = _place.text;
      request.fields['post'] = _post.text;
      request.fields['pin'] = _pin.text;
      request.fields['phone'] = _phone.text;
      request.fields['email'] = _email.text;
      request.fields['course_id'] = _selectedCourseId!;

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _profileImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LoginApp()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Failed")),
        );
      }
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
                      child: Form(
                        key: _regformkey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add,
                                size: 60, color: Colors.white),
                            const SizedBox(height: 20),
                            Text(widget.title,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 25),

                            // Full Name
                            TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(
                                labelText: "Full Name",
                                prefixIcon: Icon(Icons.person,
                                    color: Color(0xFF8B1E3F)),
                              ),
                              validator: _validateName,
                            ),
                            const SizedBox(height: 18),

                            // Gender Dropdown
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _gender,
                              hint: const Text("Select Gender"),
                              items: ["Male", "Female"]
                                  .map((g) => DropdownMenuItem(
                                  value: g, child: Text(g)))
                                  .toList(),
                              onChanged: (val) => setState(() => _gender = val),
                              validator: (val) =>
                              val == null ? "Select Gender" : null,
                              decoration: const InputDecoration(
                                labelText: "Gender",
                                prefixIcon: Icon(Icons.wc,
                                    color: Color(0xFF8B1E3F)),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Place
                            TextFormField(
                              controller: _place,
                              decoration: const InputDecoration(
                                labelText: "Place",
                                prefixIcon: Icon(Icons.location_on,
                                    color: Color(0xFF8B1E3F)),
                              ),
                              validator: (v) =>
                              v!.isEmpty ? "Place is required" : null,
                            ),
                            const SizedBox(height: 18),

                            // Post
                            TextFormField(
                              controller: _post,
                              decoration: const InputDecoration(
                                labelText: "Post",
                                prefixIcon: Icon(Icons.home,
                                    color: Color(0xFF8B1E3F)),
                              ),
                              validator: (v) =>
                              v!.isEmpty ? "Post is required" : null,
                            ),
                            const SizedBox(height: 18),

                            // Pin Code
                            TextFormField(
                              controller: _pin,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Pin Code",
                                prefixIcon: Icon(Icons.pin,
                                    color: Color(0xFF8B1E3F)),
                              ),
                              validator: _validatePin,
                            ),
                            const SizedBox(height: 18),

                            // Phone
                            TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Phone Number",
                                prefixIcon: Icon(Icons.phone,
                                    color: Color(0xFF8B1E3F)),
                              ),
                              validator: _validatePhone,
                            ),
                            const SizedBox(height: 18),

                            // Email
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email,
                                    color: Color(0xFF8B1E3F)),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 18),

                            // Username
                            TextFormField(
                              controller: _username,
                              decoration: const InputDecoration(
                                labelText: "Username",
                                prefixIcon: Icon(Icons.account_circle,
                                    color: Color(0xFF8B1E3F)),
                              ),
                              validator: (v) =>
                              v!.isEmpty ? "Username is required" : null,
                            ),
                            const SizedBox(height: 18),

                            // Password
                            TextFormField(
                              controller: _pwd,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock,
                                    color: Color(0xFF8B1E3F)),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 18),

                            // Course Dropdown
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedCourseId,
                              hint: const Text('Select Course'),
                              items: _courses
                                  .map<DropdownMenuItem<String>>((c) {
                                return DropdownMenuItem<String>(
                                  value: c['cid'].toString(),
                                  child: Text(
                                    '${c['cn']} (${c['department']})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedCourseId = value),
                              validator: (value) =>
                              value == null ? 'Please select a course' : null,
                              decoration: const InputDecoration(
                                labelText: "Course",
                                prefixIcon: Icon(Icons.school,
                                    color: Color(0xFF8B1E3F)),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Profile Image Picker
                            Column(
                              children: [
                                if (_profileImage != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _profileImage!,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                TextButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.photo,
                                      color: Color(0xFF8B1E3F)),
                                  label: const Text("Pick Profile Image",
                                      style: TextStyle(color: Colors.white)),
                                ),
                                if (_imageError)
                                  const Text("Profile photo is required",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Register Button
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
                                onPressed: _registerUser,
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
    final Paint bgPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    Path path = Path();
    double waveHeight = 30;
    double speed = progress * 2 * pi; // fixed using pi from dart:math
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
