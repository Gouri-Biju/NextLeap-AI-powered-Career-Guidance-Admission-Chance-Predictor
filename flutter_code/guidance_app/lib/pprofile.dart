import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guidance_app/parenthome.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:guidance_app/Pdfviewer.dart';

void main() {
  runApp(const ParentProfileApp());
}

class ParentProfileApp extends StatelessWidget {
  const ParentProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const ParentProfilePage(),
    );
  }
}

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? profileData;
  String? baseUrl;
  bool _isLoading = true;
  String? pdfUrl;


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
        Uri.parse('$baseUrl/api/parentprofile'),
        body: {'uid': uid},
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);

        setState(() {
          profileData = data['data'][0];

          // ✅ Assign pdfUrl here after profileData is fetched
          if (profileData!['proof_pdf'] != null && profileData!['proof_pdf'].isNotEmpty) {
            pdfUrl = profileData!['proof_pdf'];
          }

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
                  children:
                  [
                    IconButton(
                      icon: Container(
                        decoration: const BoxDecoration(
                          color: const Color(0xFF8B1E3F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 22),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ParentHome()));
                      },
                    ),
                    const SizedBox(width: 15),
                    const Text("Parent Profile",
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
                      ViewParentProfileTab(
                          profileData: profileData, baseUrl: baseUrl ?? ""),
                      EditParentProfileTab(
                          profileData: profileData,
                          onProfileUpdated: _fetchProfile),
                      const ChangeParentPasswordTab(),
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
class ViewParentProfileTab extends StatelessWidget {
  final Map<String, dynamic>? profileData;
  final String baseUrl;

  const ViewParentProfileTab({
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
              child: profileData!['photo'] != null
                  ? CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileData!['photo']),
                ),
              )
                  : const Icon(
                Icons.family_restroom,
                size: 110, // adjust size to match the outer circle
                color: Color(0xFF26A69A),
              ),
            ),

          ],
        ),
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Text(profileData!['n'],
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D405B))),
              const SizedBox(height: 5),
              Text(profileData!['e'],
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(height: 25),
        _buildInfoCard(Icons.person, "Name", profileData!['n']),
        _buildInfoCard(Icons.email, "Email", profileData!['e']),
        _buildInfoCard(Icons.phone, "Phone", profileData!['ph'].toString()),
        _buildInfoCard(Icons.location_city, "Place", profileData!['pl']),
        _buildInfoCard(Icons.school, "Student", profileData!['s']),

        // ✅ Fixed Proof PDF button block
        if (profileData!['proof_pdf'] != null &&
            profileData!['proof_pdf'].isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Proof Document",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    String pdfUrl =
                        profileData!['proof_pdf'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFViewerPage(pdfUrl: pdfUrl),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1E3F),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text("View Proof PDF",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
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
class EditParentProfileTab extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  final VoidCallback onProfileUpdated;

  const EditParentProfileTab({
    super.key,
    required this.profileData,
    required this.onProfileUpdated,
  });

  @override
  State<EditParentProfileTab> createState() => _EditParentProfileTabState();
}

class _EditParentProfileTabState extends State<EditParentProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _email, _phone, _place;
  String? baseUrl;
  TextEditingController _sid = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    if (widget.profileData != null) {
      _name = TextEditingController(text: widget.profileData!['n']);
      _email = TextEditingController(text: widget.profileData!['e']);
      _phone =
          TextEditingController(text: widget.profileData!['ph'].toString());
      _place = TextEditingController(text: widget.profileData!['pl']);
      _sid = TextEditingController(text: widget.profileData!['sid'].toString());
    }
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = sh.getString('url');
    });
  }

  File? _pickedPdf;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDFs
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedPdf = File(result.files.single.path!);
      });
    }
  }


  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? uid = sh.getString('uid');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/editpreg/'),
      );
      request.fields['uid'] = uid!;
      request.fields['name'] = _name.text;
      request.fields['email'] = _email.text;
      request.fields['phone'] = _phone.text;
      request.fields['place'] = _place.text;
      request.fields['sid'] = _sid.text;

      if (_pickedPdf != null) {
        request.files.add(await http.MultipartFile.fromPath('proof_pdf', _pickedPdf!.path));
      } else {
        request.fields['old_pdf'] = widget.profileData!['proof_pdf'] ?? '';
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
          _buildField(_email, "Email", validator: _validateEmail),
          _buildField(_phone, "Phone", isNumber: true, validator: _validatePhone),
          _buildField(_place, "Place",validator: _validatePlace),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: _pickPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1E3F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Pick Proof PDF", style: TextStyle(color: Colors.white)),
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

  Widget _buildField(TextEditingController controller, String label,
      {bool isNumber = false,
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
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
          ),
        ),
      ),
    );
  }
}

// -------------------- CHANGE PASSWORD TAB --------------------
class ChangeParentPasswordTab extends StatefulWidget {
  const ChangeParentPasswordTab({super.key});

  @override
  State<ChangeParentPasswordTab> createState() =>
      _ChangeParentPasswordTabState();
}

class _ChangeParentPasswordTabState extends State<ChangeParentPasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPwd = TextEditingController();
  final TextEditingController _newPwd = TextEditingController();
  final TextEditingController _confirmPwd = TextEditingController();
  String? baseUrl;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      baseUrl = sh.getString('url');
      String? uid = sh.getString('uid');

      var response = await http.post(
        Uri.parse('$baseUrl/api/p_change_password'),
        body: {
          'uid': uid,
          'textfield': _oldPwd.text,
          'textfield2': _newPwd.text,
          'textfield3': _confirmPwd.text,
        },
      );

      var data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
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
          _buildPasswordField(_oldPwd, "Current Password",
              validator: (v) => v!.isEmpty ? "Enter current password" : null),
          _buildPasswordField(_newPwd, "New Password",
              validator: (v) =>
              v!.length < 6 ? "Minimum 6 characters required" : null),
          _buildPasswordField(_confirmPwd, "Confirm Password",
              validator: (v) =>
              v != _newPwd.text ? "Passwords do not match" : null),
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
class VerticalSvgWavePainter extends CustomPainter {
  final bool isLeft;
  VerticalSvgWavePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF3D405B),
          const Color(0xFF5D4037),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    Path path = Path();

    if (isLeft) {
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.2,
          size.width * 0.5, size.height * 0.4);
      path.quadraticBezierTo(size.width * 0.3, size.height * 0.7,
          size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
      path.close();
    } else {
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
