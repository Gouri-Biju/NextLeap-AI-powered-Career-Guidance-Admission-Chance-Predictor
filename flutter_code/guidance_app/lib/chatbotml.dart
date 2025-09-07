import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBotPage extends StatefulWidget {
  final int userId;

  const ChatBotPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  int phase = 0;
  String question = "";
  String course = "";
  String message = "";
  String jobRecommendation = "";
  String? url;
  int datasetId = 0;
  bool isLoading = false;
  final TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchQuestion();
  }

  Future<void> fetchQuestion() async {
    setState(() => isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    url = sh.getString('url');

    try {
      final response = await http.get(
        Uri.parse('$url/chatbot/get-question/?user_id=${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          phase = data['phase'];
          if (data.containsKey('question')) {
            question = data['question'];
            course = data['course'];
            datasetId = data['dataset_id'];
            message = "";
            jobRecommendation = "";
          } else if (data.containsKey('message')) {
            message = data['message'];
            jobRecommendation = data['job_recommendation'] ?? "";
            question = "";
            course = "";
            datasetId = 0;
          }
        });
      } else {
        showSnackBar("Failed to fetch question");
      }
    } catch (e) {
      showSnackBar("Error: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> submitAnswer() async {
    if (answerController.text.isEmpty) {
      showSnackBar("Please enter your answer");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/chatbot/submit-answer/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "user_id": widget.userId,
          "dataset_id": datasetId,
          "user_answer": answerController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text("Score"),
            content: Text("Your score: ${data['score']}"),
          ),
        );

        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context, rootNavigator: true).pop();
          fetchQuestion();
          answerController.clear();
        });
      } else {
        showSnackBar("Failed to submit answer");
      }
    } catch (e) {
      showSnackBar("Error: $e");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8), // Light background
      appBar: AppBar(
        title: Text("AI Chatbot Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF800000), // Maroon color
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF800000)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phase: $phase",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF800000))),
                SizedBox(height: 20),

                if (message.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 12),

                      if (jobRecommendation.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Job Recommendation:",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF800000)),
                            ),
                            SizedBox(height: 8),
                            MarkdownBody(
                              data: jobRecommendation,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(fontSize: 16, height: 1.5),
                                strong: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                    ],
                  )
                else ...[
                  Text("Course: $course",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400)),
                  SizedBox(height: 12),
                  Text("Question: $question",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 20),
                  TextField(
                    controller: answerController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Your Answer",
                      filled: true,
                      fillColor: Color(0xFFF4F4F4),
                      labelStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF800000), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF800000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Submit Answer",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
