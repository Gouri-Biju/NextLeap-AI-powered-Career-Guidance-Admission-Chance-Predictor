import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdmissionPredictionPage extends StatefulWidget {
  const AdmissionPredictionPage({super.key, required this.title});
  final String title;

  @override
  State<AdmissionPredictionPage> createState() =>
      _AdmissionPredictionPageState();
}

class _AdmissionPredictionPageState extends State<AdmissionPredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marksController = TextEditingController();

  String? selectedStream;
  String? selectedCourseId;
  bool loading = false;

  List<dynamic> availableCourses = [];
  List<dynamic> predictions = [];

  final List<String> streams = [
    'bio-science',
    'computer-science',
    'commerce',
    'humanities',
  ];

  Future<void> _getPredictions() async {
    if (!_formKey.currentState!.validate()) return;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? uid = sh.getString('uid');

    setState(() {
      loading = true;
      predictions = [];
      availableCourses = [];
    });

    var bodyData = {
      'uid': uid,
      'marks': _marksController.text.trim(),
      'stream': selectedStream!,
    };

    if (selectedCourseId != null) {
      bodyData['course_id'] = selectedCourseId!;
    }

    var response = await http.post(
      Uri.parse('$url/api/admission_prediction/'),
      body: bodyData,
    );

    setState(() {
      loading = false;
    });

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      setState(() {
        predictions = result['predictions'];
        availableCourses = result['available_courses'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch predictions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCard(dynamic item) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("College:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(item['college'],
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const Divider(height: 20, thickness: 1.2, color: Color(0xFFBDBDBD)),
            const Text("Course:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1E3F))),
            const SizedBox(height: 4),
            Text(item['course'],
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text("Chance: ${item['chance'].toStringAsFixed(2)}%",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter predictions if a course is selected
    List<dynamic> filteredPredictions = selectedCourseId == null
        ? predictions
        : predictions
        .where((p) => p['course_id'].toString() == selectedCourseId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF8B1E3F),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _marksController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter the marks',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Marks cannot be empty';
                          }
                          double? marks = double.tryParse(value);
                          if (marks == null) return 'Enter a valid number';
                          if (marks < 0 || marks > 100) return 'Marks must be between 0 and 100';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedStream,
                        hint: const Text('Select the stream'),
                        items: streams
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStream = value;
                            selectedCourseId = null; // reset course selection
                            predictions = [];
                            availableCourses = [];
                          });
                        },
                        validator: (value) =>
                        value == null ? 'Please select a stream' : null,
                      ),
                      const SizedBox(height: 20),
                      if (availableCourses.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: selectedCourseId,
                          hint: const Text('Select course (optional)'),
                          items: availableCourses.map((c) {
                            return DropdownMenuItem(
                              value: c['course_id'].toString(),
                              child: Text(c['course_name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCourseId = value;
                            });
                          },
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B1E3F),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          onPressed: _getPredictions,
                          child: const Text("Get Predictions",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                if (loading)
                  const Center(child: CircularProgressIndicator()),
                if (!loading && filteredPredictions.isEmpty)
                  const Center(
                      child: Text('No predictions yet',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600))),
                if (filteredPredictions.isNotEmpty)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredPredictions.length,
                    itemBuilder: (context, index) =>
                        _buildCard(filteredPredictions[index]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
