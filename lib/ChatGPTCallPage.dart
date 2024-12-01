import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatGPTCallPage extends StatefulWidget {
  @override
  _ChatGPTCallPageState createState() => _ChatGPTCallPageState();
}

class _ChatGPTCallPageState extends State<ChatGPTCallPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late stt.SpeechToText _speech;
  late FlutterTts _tts;

  String userQuery = "Listening...";
  String assistantResponse = "How can I assist you today?";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);

    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    // Start listening as soon as the page loads
    _startListening();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        setState(() {
          userQuery = result.recognizedWords;
        });

        // Simulate sending the query to ChatGPT and getting a response
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            assistantResponse = "I heard: $userQuery. The home is fine!";
          });
          _tts.speak(assistantResponse); // Speak out the response
        });
      });
    } else {
      setState(() {
        userQuery = "Speech recognition unavailable.";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Assistant Call'),
        backgroundColor: const Color(0xFFFDFFE2),
        foregroundColor: const Color(0xFF1c231f),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ScaleTransition(
              scale: _animation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,

                ),
                padding: const EdgeInsets.all(70),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userQuery,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            assistantResponse,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // End the call
            },
            child: const Text("End Call"),
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF1c231f),
              backgroundColor: const Color(0xFFFDFFE2),
            ),
          ),
        ],
      ),
    );
  }
}
