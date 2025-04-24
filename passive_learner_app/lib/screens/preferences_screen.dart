import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../services/api_service.dart';
import 'content_screen.dart';

class PreferencesScreen extends StatefulWidget {
  final String? pdfPath;
  final Content? initialContent;

  const PreferencesScreen({
    Key? key,
    this.pdfPath,
    this.initialContent,
  }) : super(key: key);

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late final ApiService _apiService;
  late UserPreferences _preferences;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiService = ApiService(prefs);
      _preferences = await UserPreferences.load(prefs);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    try {
      await _preferences.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          if (widget.pdfPath != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentScreen(
                      pdfPath: widget.pdfPath!,
                      content: widget.initialContent,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: _preferences.geminiApiKey,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'Enter your Gemini API key',
              ),
              onChanged: (value) => _preferences.geminiApiKey = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _preferences.bookTitle,
              decoration: const InputDecoration(
                labelText: 'Book Title',
                hintText: 'Enter the book title',
              ),
              onChanged: (value) => _preferences.bookTitle = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _preferences.chapterTitle,
              decoration: const InputDecoration(
                labelText: 'Chapter Title',
                hintText: 'Enter the chapter title',
              ),
              onChanged: (value) => _preferences.chapterTitle = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePreferences,
              child: const Text('Save Preferences'),
            ),
            if (widget.initialContent != null) ...[
              const SizedBox(height: 32),
              const Text(
                'Generated Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '10-Word Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.initialContent!.tenWordSummary),
              const SizedBox(height: 16),
              const Text(
                '50-Word Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.initialContent!.fiftyWordSummary),
            ],
          ],
        ),
      ),
    );
  }
} 