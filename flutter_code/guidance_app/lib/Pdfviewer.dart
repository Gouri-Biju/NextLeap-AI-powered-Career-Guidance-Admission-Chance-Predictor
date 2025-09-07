import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  const PDFViewerPage({super.key, required this.pdfUrl});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadPDF(tempOnly: true); // just for viewing
  }

  /// Downloads the PDF
  /// If [tempOnly] is true, it saves in temp folder (for viewing)
  /// If [tempOnly] is false, it saves in Downloads folder
  Future<void> _downloadPDF({bool tempOnly = false}) async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final dir = tempOnly
          ? await getTemporaryDirectory()
          : Directory("/storage/emulated/0/Download"); // Android Downloads folder

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File("${dir.path}/result.pdf");
      await file.writeAsBytes(response.bodyBytes, flush: true);

      if (tempOnly) {
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Downloaded to: ${file.path}")),
        );
      }
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPDF(tempOnly: false),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
      ),
    );
  }
}