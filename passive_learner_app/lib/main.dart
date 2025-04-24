import 'package:flutter/material.dart';
import 'screens/pdf_upload_screen.dart';
import 'services/storage_service.dart';
import 'models/user_preferences.dart';
import 'screens/content_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passive Learner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PdfUploadScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final _storageService = StorageService();
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isProcessing = false;
  double _uploadProgress = 0.0;
  double _processingProgress = 0.0;
  UserPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _simulateUploadAndProcessing();
  }

  Future<void> _simulateUploadAndProcessing() async {
    // Initial loading
    await Future.delayed(const Duration(milliseconds: 700));
    
    setState(() {
      _isLoading = false;
      _isUploading = true;
    });

    // Simulate file upload
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _uploadProgress = i / 100;
      });
    }

    setState(() {
      _isUploading = false;
      _isProcessing = true;
    });

    // Simulate processing
    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        _processingProgress = i / 100;
      });
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isUploading || _isProcessing) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isUploading ? 'Uploading PDF...' : 'Processing PDF...'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isUploading) ...[
                const Text('Uploading Atomic Habits.pdf...'),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 10),
                Text('${(_uploadProgress * 100).toInt()}%'),
              ] else ...[
                const Text('Processing PDF content...'),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: _processingProgress),
                const SizedBox(height: 10),
                Text('${(_processingProgress * 100).toInt()}%'),
                const SizedBox(height: 20),
                const Text(
                  'Generating summaries...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Show content after processing
    return ContentScreen(
      pdfPath: 'atomic_habits.pdf',
      content: Content.atomicHabits(),
    );
  }
}
