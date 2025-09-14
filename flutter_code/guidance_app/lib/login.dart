import 'dart:ui';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guidance_app/parenthome.dart';
import 'package:guidance_app/preg.dart';
import 'package:guidance_app/register.dart';
import 'package:guidance_app/studenthome.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

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
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const LoginPage(title: 'Login'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _lfkey = GlobalKey<FormState>();
  final TextEditingController _uname = TextEditingController();
  final TextEditingController _pwd = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setUrlAndNavigate();
  }

  Future<void> _setUrlAndNavigate() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    await sh.setString(
      "url",
      "http://192.168.29.230:8002",
    );

  }


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
    _uname.dispose();
    _pwd.dispose();
    super.dispose();
  }

  // ----------- Validators -----------
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username is required";
    }
    final nameRegex = RegExp(r'^[A-Za-z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return "Only letters allowed (no numbers/symbols)";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Minimum 8 characters required";
    }
    final upper = RegExp(r'[A-Z]');
    final lower = RegExp(r'[a-z]');
    final digit = RegExp(r'\d');
    final special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!upper.hasMatch(value) ||
        !lower.hasMatch(value) ||
        !digit.hasMatch(value) ||
        !special.hasMatch(value)) {
      return "Password must contain uppercase, lowercase, number & special character";
    }
    return null;
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
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8B1E3F), Color(0xFF2C3145)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(Icons.lock,
                                    size: 55, color: Colors.white),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Form(
                                key: _lfkey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _uname,
                                      decoration: const InputDecoration(
                                        labelText: "Username",
                                        prefixIcon: Icon(Icons.person,
                                            color: Color(0xFF8B1E3F)),
                                      ),
                                      validator: _validateUsername,
                                    ),
                                    const SizedBox(height: 18),
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
                                        onPressed: () async {
                                          if (_lfkey.currentState!.validate()) {
                                            SharedPreferences sh =
                                            await SharedPreferences.getInstance();
                                            String? url = sh.getString('url');
                                            String uname = _uname.text;
                                            String pwd = _pwd.text;

                                            var response = await http.post(
                                              Uri.parse('$url/api/applogin/'),
                                              body: {'uname': uname, 'pwd': pwd},
                                            );
                                            final result = json.decode(response.body);
                                            String? type = result['type'];

                                            String? status =
                                            result['status'].toString();
                                            if (status == "Invalid Username or Password") {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Invalid Username or Password"),
                                                  backgroundColor: Colors.redAccent,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                              return;
                                            }
                                            String? uid =
                                            result['uid'].toString();
                                            String? uimg =
                                            result['uimg'].toString();
                                            sh.setString('uid', uid);
                                            sh.setString('uimg', uimg);
                                            if (status == "Invalid Username or Password") {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Invalid Username or Password"),
                                                  backgroundColor: Colors.redAccent,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                              return; // stop further navigation
                                            }

                                            if (type == 'Student') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const StudentApp()),
                                              );
                                            } else if (type == 'Parent') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const ParentHome()),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(status),
                                                  backgroundColor:
                                                  const Color(0xFF8B1E3F),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text(
                                          "Login",
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const RegApp()),
                                        );
                                      },
                                      child: const Text(
                                        "Student Registration",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const ParentRegApp()),
                                        );
                                      },
                                      child: const Text(
                                        "Parent Registration",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
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

/// Custom bluish-ash wave painter
class ModernWavePainter extends CustomPainter {
  final double progress;
  ModernWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = const LinearGradient(
      colors: [
        Color(0xFF2C3145),
        Color(0xFF3D405B),
        Color(0xFF8B1E3F),
      ],
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
