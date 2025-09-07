import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const ParentProfileApp());
}

class ParentProfileApp extends StatelessWidget {
  const ParentProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Profile',
      home: const ParentProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  String? url;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    url = sh.getString('url');
    String? uid = sh.getString('uid');

    var response = await http.post(
      Uri.parse('$url/api/parentprofile'),
      body: {'uid': uid},
    );

    final result = json.decode(response.body);
    setState(() {
      profileData = result['data'][0];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (profileData == null) {
      return const Scaffold(
        body: Center(child: Text("Loading profile...")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Parent Profile")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${profileData!['n']}"),
            Text("Email: ${profileData!['e']}"),
            Text("Phone: ${profileData!['ph']}"),
            Text("Place: ${profileData!['pl']}"),
            Text("Student: ${profileData!['s']}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditParentProfilePage(
                      name: profileData!['n'],
                      email: profileData!['e'],
                      phone: profileData!['ph'],
                      place: profileData!['pl'],
                      student: profileData!['s'],
                      photo: profileData!['photo'],
                    ),
                  ),
                );
              },
              child: const Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditParentProfilePage extends StatefulWidget {
  final String name, email, phone, place, student, photo;
  const EditParentProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.place,
    required this.student,
    required this.photo,
  });

  @override
  State<EditParentProfilePage> createState() => _EditParentProfilePageState();
}

class _EditParentProfilePageState extends State<EditParentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _place;
  late TextEditingController _sid;


  String? baseUrl;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.name);
    _email = TextEditingController(text: widget.email);
    _phone = TextEditingController(text: widget.phone);
    _place = TextEditingController(text: widget.place);
    _sid = TextEditingController(); // student id to be filled manually
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = sh.getString('url');
    });
  }

  File? _pickedPDF;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedPDF = File(result.files.single.path!);
      });
    }
  }


  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? uid = sh.getString('uid');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$url/api/editpreg/'),
      );
      request.fields['uid'] = uid!;
      request.fields['name'] = _name.text;
      request.fields['email'] = _email.text;
      request.fields['phone'] = _phone.text;
      request.fields['place'] = _place.text;
      request.fields['sid'] = _sid.text;

      if (_pickedPDF != null) {
        request.files.add(
          await http.MultipartFile.fromPath('document', _pickedPDF!.path), // 'document' as key
        );
      } else {
        request.fields['old_photo'] = widget.photo; // Keep old field for compatibility
      }


      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      print("Update Response: $respStr");

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Parent Profile")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: "Name")),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: "Phone")),
              TextFormField(controller: _place, decoration: const InputDecoration(labelText: "Place")),
              TextFormField(controller: _sid, decoration: const InputDecoration(labelText: "Student ID")),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _pickPDF, child: const Text("Pick Proof PDF")),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _updateProfile, child: const Text("Update")),
            ],
          ),
        ),
      ),
    );
  }
}
