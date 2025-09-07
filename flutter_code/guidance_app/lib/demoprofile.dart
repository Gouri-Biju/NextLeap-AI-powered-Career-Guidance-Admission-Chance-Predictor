// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:guidance_app/studenthome.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// void main() {
//   runApp(const StudentProfileApp());
// }
//
// class StudentProfileApp extends StatelessWidget {
//   const StudentProfileApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Student Profile',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'Poppins',
//         useMaterial3: true,
//       ),
//       home: const StudentProfilePage(),
//     );
//   }
// }
//
// class StudentProfilePage extends StatefulWidget {
//   const StudentProfilePage({super.key});
//
//   @override
//   State<StudentProfilePage> createState() => _StudentProfilePageState();
// }
//
// class _StudentProfilePageState extends State<StudentProfilePage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   Map<String, dynamic>? profileData;
//   String? baseUrl;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchProfile();
//   }
//
//   Future<void> _fetchProfile() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     baseUrl = sh.getString('url');
//     String? uid = sh.getString('uid');
//
//     try {
//       var res = await http.post(
//         Uri.parse('$baseUrl/api/studentprofile/'),
//         body: {'uid': uid},
//       );
//
//       if (res.statusCode == 200) {
//         var data = jsonDecode(res.body);
//         setState(() {
//           profileData = data['data'][0];
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Align(
//             alignment: Alignment.centerLeft,
//             child: CustomPaint(
//               size: Size(80, MediaQuery.of(context).size.height),
//               painter: VerticalSvgWavePainter(isLeft: true),
//             ),
//           ),
//           Positioned(
//             right: 20,
//             top: 80,
//             child: Icon(Icons.school,
//                 size: 100, color: const Color(0xFF8B1E3F).withOpacity(0.12)),
//           ),
//           Positioned(
//             right: 40,
//             top: 250,
//             child: Icon(Icons.person,
//                 size: 90, color: const Color(0xFF5D4037).withOpacity(0.12)),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back,
//                           color: Color(0xFF8B1E3F), size: 26),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const StudentApp()),
//                         );
//                       },
//                     ),
//                     const Text("Student Profile",
//                         style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF8B1E3F))),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 TabBar(
//                   controller: _tabController,
//                   labelColor: const Color(0xFF8B1E3F),
//                   unselectedLabelColor: Colors.grey,
//                   indicatorColor: const Color(0xFF8B1E3F),
//                   tabs: const [
//                     Tab(text: "View"),
//                     Tab(text: "Edit"),
//                     Tab(text: "Change Password"),
//                   ],
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       ViewProfileTab(
//                           profileData: profileData, baseUrl: baseUrl ?? ""),
//                       EditProfileTab(
//                           profileData: profileData,
//                           onProfileUpdated: _fetchProfile),
//                       const ChangePasswordTab(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // -------------------- VIEW PROFILE TAB --------------------
// class ViewProfileTab extends StatelessWidget {
//   final Map<String, dynamic>? profileData;
//   final String baseUrl;
//
//   const ViewProfileTab({
//     super.key,
//     required this.profileData,
//     required this.baseUrl,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (profileData == null) {
//       return const Center(child: Text("No profile data found"));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         elevation: 6,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: ListView(
//             children: [
//               CircleAvatar(
//                 radius: 50,
//                 backgroundImage: profileData!['image'] != null
//                     ? NetworkImage(
//                     "$baseUrl/static/media/${profileData!['image']}")
//                     : null,
//                 child: profileData!['image'] == null
//                     ? const Icon(Icons.person, size: 50)
//                     : null,
//               ),
//               const SizedBox(height: 20),
//               Text("Name: ${profileData!['name']}"),
//               Text("Gender: ${profileData!['gender']}"),
//               Text("Place: ${profileData!['place']}"),
//               Text("Post: ${profileData!['post']}"),
//               Text("PIN: ${profileData!['pin']}"),
//               Text("Phone: ${profileData!['phone']}"),
//               Text("Email: ${profileData!['email']}"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // -------------------- EDIT PROFILE TAB --------------------
// class EditProfileTab extends StatefulWidget {
//   final Map<String, dynamic>? profileData;
//   final VoidCallback onProfileUpdated;
//
//   const EditProfileTab({
//     super.key,
//     required this.profileData,
//     required this.onProfileUpdated,
//   });
//
//   @override
//   State<EditProfileTab> createState() => _EditProfileTabState();
// }
//
// class _EditProfileTabState extends State<EditProfileTab> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _name, _gender, _place, _post, _pin, _phone, _email;
//   File? _pickedImage;
//   String? baseUrl;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.profileData != null) {
//       _name = TextEditingController(text: widget.profileData!['name']);
//       _gender = TextEditingController(text: widget.profileData!['gender']);
//       _place = TextEditingController(text: widget.profileData!['place']);
//       _post = TextEditingController(text: widget.profileData!['post']);
//       _pin = TextEditingController(text: widget.profileData!['pin'].toString());
//       _phone =
//           TextEditingController(text: widget.profileData!['phone'].toString());
//       _email = TextEditingController(text: widget.profileData!['email']);
//     }
//     _loadUrl();
//   }
//
//   Future<void> _loadUrl() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     setState(() {
//       baseUrl = sh.getString('url');
//     });
//   }
//
//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _pickedImage = File(picked.path);
//       });
//     }
//   }
//
//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String? uid = sh.getString('uid');
//
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/api/editsreg/'),
//       );
//
//       request.fields['uid'] = uid!;
//       request.fields['name'] = _name.text;
//       request.fields['gender'] = _gender.text;
//       request.fields['place'] = _place.text;
//       request.fields['post'] = _post.text;
//       request.fields['pin'] = _pin.text;
//       request.fields['phone'] = _phone.text;
//       request.fields['email'] = _email.text;
//
//       if (_pickedImage != null) {
//         request.files
//             .add(await http.MultipartFile.fromPath('image', _pickedImage!.path));
//       }
//
//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();
//       var data = jsonDecode(respStr);
//
//       if (data['status'] == 'success') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text("Profile Updated Successfully"),
//               backgroundColor: Color(0xFF8B1E3F)),
//         );
//         widget.onProfileUpdated();
//       }
//     }
//   }
//
//   String? _validateName(String? value) {
//     if (value == null || value.trim().isEmpty) return "Name is required";
//     if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
//       return "Name must contain only letters";
//     }
//     return null;
//   }
//
//   String? _validatePin(String? value) {
//     if (value == null || value.isEmpty) return "PIN is required";
//     if (!RegExp(r'^\d+$').hasMatch(value)) return "PIN must contain only digits";
//     if (value.length != 6) return "PIN must be 6 digits";
//     return null;
//   }
//
//   String? _validatePhone(String? value) {
//     if (value == null || value.isEmpty) return "Phone is required";
//     if (!RegExp(r'^\d{10}$').hasMatch(value)) {
//       return "Enter a valid 10-digit phone number";
//     }
//     return null;
//   }
//
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) return "Email is required";
//     if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
//       return "Enter a valid email address";
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.profileData == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: ListView(
//           children: [
//             TextFormField(
//               controller: _name,
//               decoration: const InputDecoration(labelText: "Name"),
//               validator: _validateName,
//             ),
//             TextFormField(
//               controller: _gender,
//               decoration: const InputDecoration(labelText: "Gender"),
//               validator: _validateName,
//             ),
//             TextFormField(
//               controller: _place,
//               decoration: const InputDecoration(labelText: "Place"),
//               validator: _validateName,
//             ),
//             TextFormField(
//               controller: _post,
//               decoration: const InputDecoration(labelText: "Post"),
//               validator: _validateName,
//             ),
//             TextFormField(
//               controller: _pin,
//               decoration: const InputDecoration(labelText: "PIN"),
//               validator: _validatePin,
//             ),
//             TextFormField(
//               controller: _phone,
//               decoration: const InputDecoration(labelText: "Phone"),
//               validator: _validatePhone,
//             ),
//             TextFormField(
//               controller: _email,
//               decoration: const InputDecoration(labelText: "Email"),
//               validator: _validateEmail,
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _pickImage,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF8B1E3F),
//               ),
//               child: const Text("Pick Profile Image",
//                   style: TextStyle(color: Colors.white)),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _updateProfile,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF8B1E3F),
//               ),
//               child: const Text("Update Profile",
//                   style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // -------------------- CHANGE PASSWORD TAB --------------------
// class ChangePasswordTab extends StatefulWidget {
//   const ChangePasswordTab({super.key});
//
//   @override
//   State<ChangePasswordTab> createState() => _ChangePasswordTabState();
// }
//
// class _ChangePasswordTabState extends State<ChangePasswordTab> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _oldPwd = TextEditingController();
//   final TextEditingController _newPwd = TextEditingController();
//   final TextEditingController _confirmPwd = TextEditingController();
//   String? baseUrl;
//
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) return "Password is required";
//     if (value.length < 8) {
//       return "Password must be at least 8 characters";
//     }
//     if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$')
//         .hasMatch(value)) {
//       return "Password must contain upper, lower, number & special char";
//     }
//     return null;
//   }
//
//   Future<void> _changePassword() async {
//     if (_formKey.currentState!.validate()) {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       baseUrl = sh.getString('url');
//       String? uid = sh.getString('uid');
//
//       var response = await http.post(
//         Uri.parse('$baseUrl/api/change_password/'),
//         body: {
//           'uid': uid,
//           'old_password': _oldPwd.text,
//           'new_password': _newPwd.text,
//           'conf_pwd': _confirmPwd.text,
//         },
//       );
//
//       var data = jsonDecode(response.body);
//
//       if (data['status'] == 'success') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text("Password Changed Successfully"),
//               backgroundColor: Color(0xFF8B1E3F)),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? "Error changing password")),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: ListView(
//           children: [
//             TextFormField(
//               controller: _oldPwd,
//               decoration: const InputDecoration(labelText: "Old Password"),
//               obscureText: true,
//               validator: (value) =>
//               value!.isEmpty ? "Enter old password" : null,
//             ),
//             TextFormField(
//               controller: _newPwd,
//               decoration: const InputDecoration(labelText: "New Password"),
//               obscureText: true,
//               validator: _validatePassword,
//             ),
//             TextFormField(
//               controller: _confirmPwd,
//               decoration:
//               const InputDecoration(labelText: "Confirm New Password"),
//               obscureText: true,
//               validator: (value) =>
//               value != _newPwd.text ? "Passwords do not match" : null,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _changePassword,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF8B1E3F),
//               ),
//               child: const Text("Change Password",
//                   style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // -------------------- WAVE BACKGROUND --------------------
// class VerticalSvgWavePainter extends CustomPainter {
//   final bool isLeft;
//   VerticalSvgWavePainter({required this.isLeft});
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..shader = LinearGradient(
//         colors: [const Color(0xFF3D405B), const Color(0xFF5D4037)],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
//       ..style = PaintingStyle.fill;
//     Path path = Path();
//     path.moveTo(size.width, 0);
//     path.quadraticBezierTo(size.width * 0.3, size.height * 0.2,
//         size.width, size.height * 0.4);
//     path.quadraticBezierTo(size.width * 0.5, size.height * 0.6,
//         size.width, size.height * 0.8);
//     path.quadraticBezierTo(size.width * 0.3, size.height * 0.9,
//         size.width, size.height);
//     path.lineTo(0, size.height);
//     path.lineTo(0, 0);
//     path.close();
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
