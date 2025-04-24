import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_preferences.dart';
import '../services/api_service.dart';
import 'content_screen.dart';

class PdfUploadScreen extends StatefulWidget {
  const PdfUploadScreen({Key? key}) : super(key: key);

  @override
  _PdfUploadScreenState createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  late final ApiService _apiService;
  String? _fileName;
  List<int>? _fileBytes;
  bool _isProcessing = false;
  String? _error;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = result.files.single;
        setState(() {
          _fileName = file.name;
          _fileBytes = file.bytes;
        });

        if (_fileBytes != null) {
          await _processPDF();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _processPDF() async {
    if (_fileBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _showContent = true;
      });
    }
  }

  void _navigateToDetailedSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentScreen(
          pdfPath: _fileName ?? 'uploaded_file.pdf',
          content: Content.atomicHabits(), // Always show Atomic Habits content
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload PDF'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              Text('Processing ${_fileName ?? 'PDF'}...'),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Generating summaries...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ] else if (_showContent) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _navigateToDetailedSummary,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Atomic Habits: Tiny Changes, Remarkable Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Atomic Habits by James Clear teaches how small, consistent changes can lead to remarkable results. The book explains the science of habit formation, breaking down the process into four laws: make it obvious, make it attractive, make it easy, and make it satisfying. Clear emphasizes that success comes from focusing on systems rather than goals.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              if (_fileName != null)
                Text('Selected PDF: $_fileName')
              else
                const Text('No PDF selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isProcessing ? null : _pickPDF,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Select PDF'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 