import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guidance_app/demo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BotApp());
}

class BotApp extends StatelessWidget {
  const BotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Guidance Chatbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BotPage(title: 'Career Guidance Chatbot'),
    );
  }
}

class BotPage extends StatefulWidget {
  const BotPage({super.key, required this.title});
  final String title;

  @override
  State<BotPage> createState() => _BotPageState();
}

class _BotPageState extends State<BotPage> {
  final TextEditingController _chat = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? botResponse; // To store chatbot reply

  Future<void> sendMessage() async {
    if (_chat.text.trim().isEmpty) return;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? chat = _chat.text;

    try {
      var response = await http.post(
        Uri.parse('$url/api/chatbot'),
        body: {'chat': chat},
      );

      final result = json.decode(response.body);
      setState(() {
        botResponse = result['data'];
      });
    }

  catch (e) {
      setState(() {
        botResponse = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentApp()),
            );
          },
        ),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Chat with Career Guidance Bot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _chat,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your message',
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Send', style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 20),
            if (botResponse != null)
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Bot: $botResponse",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
