import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class CameraPage extends StatefulWidget {
  final String cameraUrl;

  const CameraPage({super.key, required this.cameraUrl});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String? _responseUrl;

  @override
  void initState() {
    super.initState();
    _fetchStreamUrl();
  }

  Future<void> _fetchStreamUrl() async {
    try {
      final response = await http.get(Uri.parse(widget.cameraUrl));
      if (response.statusCode == 200) {
        setState(() {
          _responseUrl = widget.cameraUrl;
        });
      } else {
        setState(() {
          _responseUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        _responseUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Stream'),
        backgroundColor: const Color(0xFFFFFFFF), // White background
        foregroundColor: const Color(0xFF202C33), // Dark text color
      ),
      body: Container(
        color: const Color(0xFF202C33), // Dark background for the body
        child: _responseUrl != null
            ? WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(_responseUrl!)),
        )
            : const Center(
          child: Text(
            'Unable to load camera stream',
            style: TextStyle(color: Colors.white), // White text color
          ),
        ),
      ),
    );
  }
}
