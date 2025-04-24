import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ContentScreen extends StatefulWidget {
  final String pdfPath;
  final Content? content;

  const ContentScreen({
    Key? key,
    required this.pdfPath,
    this.content,
  }) : super(key: key);

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late final ApiService _apiService;
  final _storageService = StorageService();
  Content? _content;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _content = widget.content;
    setState(() {
      _isLoading = false;
    });
  }

  void _showFullContent(BuildContext context) {
    if (_content == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _content!.tenWordSummary,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _content!.fiftyWordSummary,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _content!.fiveHundredWordSummary,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        title: const Text('Content'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_content != null) ...[
              const Text(
                '10-Word Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_content!.tenWordSummary),
              const SizedBox(height: 16),
              const Text(
                '50-Word Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_content!.fiftyWordSummary),
              const SizedBox(height: 16),
              const Text(
                '500-Word Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_content!.fiveHundredWordSummary),
            ] else
              const Center(child: Text('No content available')),
          ],
        ),
      ),
    );
  }
} 