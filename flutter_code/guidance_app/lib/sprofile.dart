import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guidance_app/studenthome.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StudentProfileApp());
}

class StudentProfileApp extends StatelessWidget {
  const StudentProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const StudentProfilePage(),
    );
  }
}

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? profileData;
  String? baseUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString('url');
    String? uid = sh.getString('uid');

    try {
      var res = await http.post(
        Uri.parse('$baseUrl/api/studentprofile/'),
        body: {'uid': uid},
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        setState(() {
          profileData = data['data'][0];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
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
                    const Text("Student Profile",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B1E3F))),
                  ],
                ),
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF8B1E3F),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF8B1E3F),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "View"),
                    Tab(text: "Edit"),
                    Tab(text: "Change Password"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ViewProfileTab(
                          profileData: profileData, baseUrl: baseUrl ?? ""),
                      EditProfileTab(
                          profileData: profileData,
                          onProfileUpdated: _fetchProfile),
                      const ChangePasswordTab(),
                    ],
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

// -------------------- VIEW PROFILE TAB --------------------
class ViewProfileTab extends StatelessWidget {
  final Map<String, dynamic>? profileData;
  final String baseUrl;

  const ViewProfileTab({
    super.key,
    required this.profileData,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (profileData == null) {
      return const Center(child: Text("No profile data found"));
    }

    return ListView(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B1E3F), Color(0xFF5D4037)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileData!['image'] != null
                      ? NetworkImage(
                      "$baseUrl/static/media/${profileData!['image']}")
                      : null,
                  child: profileData!['image'] == null
                      ? const Icon(Icons.person,
                      size: 50, color: Colors.grey)
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Text(profileData!['name'],
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D405B))),
              const SizedBox(height: 5),
              Text(profileData!['email'],
                  style:
                  const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(height: 25),
        _buildInfoCard(Icons.person, "Gender", profileData!['gender']),
        _buildInfoCard(Icons.location_city, "Place", profileData!['place']),
        _buildInfoCard(Icons.home, "Post", profileData!['post']),
        _buildInfoCard(Icons.pin, "PIN", profileData!['pin'].toString()),
        _buildInfoCard(Icons.phone, "Phone", profileData!['phone'].toString()),
        _buildInfoCard(Icons.email, "Email", profileData!['email']),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF8B1E3F).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF8B1E3F)),
        ),
        title: Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ),
    );
  }
}

// -------------------- EDIT PROFILE TAB --------------------
class EditProfileTab extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  final VoidCallback onProfileUpdated;

  const EditProfileTab({
    super.key,
    required this.profileData,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<EditProfileTab> {
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name is required";
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) return "Only letters allowed";
    return null;
  }
  String? _validatePlace(String? value) {
    if (value == null || value.trim().isEmpty) return "Place is required";
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) return "Only letters allowed";
    return null;
  }
  String? _validatePost(String? value) {
    if (value == null || value.trim().isEmpty) return "Post is required";
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) return "Only letters allowed";
    return null;
  }
  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) return "PIN is required";
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) return "PIN must be 6 digits";
    return null;
  }
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Phone is required";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Phone must be 10 digits";
    return null;
  }
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return "Invalid email format";
    return null;
  }

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _place, _post, _pin, _phone, _email;
  File? _pickedImage;
  String? baseUrl;
  String _selectedGender = "Male";

  @override
  void initState() {
    super.initState();
    if (widget.profileData != null) {
      _name = TextEditingController(text: widget.profileData!['name']);
      _place = TextEditingController(text: widget.profileData!['place']);
      _post = TextEditingController(text: widget.profileData!['post']);
      _pin = TextEditingController(text: widget.profileData!['pin'].toString());
      _phone =
          TextEditingController(text: widget.profileData!['phone'].toString());
      _email = TextEditingController(text: widget.profileData!['email']);
      _selectedGender = widget.profileData!['gender'] ?? "Male";
    }
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = sh.getString('url');
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? uid = sh.getString('uid');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/editsreg/'),
      );

      request.fields['uid'] = uid!;
      request.fields['name'] = _name.text;
      request.fields['gender'] = _selectedGender;
      request.fields['place'] = _place.text;
      request.fields['post'] = _post.text;
      request.fields['pin'] = _pin.text;
      request.fields['phone'] = _phone.text;
      request.fields['email'] = _email.text;

      if (_pickedImage != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', _pickedImage!.path));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile Updated Successfully"),
              backgroundColor: Color(0xFF8B1E3F)),
        );
        widget.onProfileUpdated();
      }
    }
  }

  Widget _buildField(TextEditingController controller, String label,
      {bool isEmail = false,
        bool isNumber = false,
        String? Function(String?)? validator}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: isNumber
              ? TextInputType.number
              : (isEmail ? TextInputType.emailAddress : TextInputType.text),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profileData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          _buildField(_name, "Name", validator: _validateName),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Gender",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Radio<String>(
                        value: "Male",
                        groupValue: _selectedGender,
                        activeColor: const Color(0xFF8B1E3F),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const Text("Male"),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: "Female",
                        groupValue: _selectedGender,
                        activeColor: const Color(0xFF8B1E3F),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const Text("Female"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildField(_place, "Place", validator: _validatePlace),
          _buildField(_post, "Post",  validator: _validatePost),
          _buildField(_pin, "PIN",  isNumber: true, validator: _validatePin),
          _buildField(_phone, "Phone", isNumber: true, validator: _validatePhone),
          _buildField(_email, "Email", isEmail: true, validator: _validateEmail),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1E3F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Pick Profile Image",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1E3F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Update Profile",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- CHANGE PASSWORD TAB --------------------
class ChangePasswordTab extends StatefulWidget {
  const ChangePasswordTab({super.key});

  @override
  State<ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<ChangePasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPwd = TextEditingController();
  final TextEditingController _newPwd = TextEditingController();
  final TextEditingController _confirmPwd = TextEditingController();
  String? baseUrl;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$')
        .hasMatch(value)) {
      return "Password must contain upper, lower, number & special char";
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      baseUrl = sh.getString('url');
      String? uid = sh.getString('uid');

      var response = await http.post(
        Uri.parse('$baseUrl/api/change_password/'),
        body: {
          'uid': uid,
          'old_password': _oldPwd.text,
          'new_password': _newPwd.text,
          'conf_pwd': _confirmPwd.text,
        },
      );

      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password Changed Successfully"),
              backgroundColor: Color(0xFF8B1E3F)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error changing password")),
        );
      }
    }
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      {String? Function(String?)? validator}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: TextFormField(
          controller: controller,
          validator: validator,
          obscureText: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          _buildPasswordField(_oldPwd, "Old Password"),
          _buildPasswordField(_newPwd, "New Password",
              validator: _validatePassword),
          _buildPasswordField(_confirmPwd, "Confirm New Password",
              validator: (value) =>
              value != _newPwd.text ? "Passwords do not match" : null),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1E3F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Change Password",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- WAVE BACKGROUND --------------------
// -------------------- WAVE BACKGROUND --------------------
class VerticalSvgWavePainter extends CustomPainter {
  final bool isLeft;
  VerticalSvgWavePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF3D405B), // bluish shade
          const Color(0xFF5D4037), // dark brown
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    Path path = Path();

    if (isLeft) {
      // Left side wave
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.2,
          size.width * 0.5, size.height * 0.4);
      path.quadraticBezierTo(size.width * 0.3, size.height * 0.7,
          size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
      path.close();
    } else {
      // Right side wave
      path.moveTo(0, 0);
      path.quadraticBezierTo(size.width * 0.3, size.height * 0.2,
          size.width * 0.5, size.height * 0.4);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.7,
          0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

