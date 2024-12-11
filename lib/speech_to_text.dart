import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextControl extends StatefulWidget {
  final Function(String) onCommandRecognized;

  const SpeechToTextControl({Key? key, required this.onCommandRecognized}) : super(key: key);

  @override
  _SpeechToTextControlState createState() => _SpeechToTextControlState();
}

class _SpeechToTextControlState extends State<SpeechToTextControl> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      await _speech.listen(onResult: (result) {
        if (result.hasConfidenceRating && result.confidence > 0.5) {
          widget.onCommandRecognized(result.recognizedWords);
          // After processing the command, restart listening
          _restartListening();
        }
      });
    } else {
      setState(() {
        // Handle the case where speech recognition is not available
      });
    }
  }

  void _restartListening() async {
    await _speech.stop(); // Stop current listening
    await _speech.listen(onResult: (result) {
      if (result.hasConfidenceRating && result.confidence > 0.5) {
        widget.onCommandRecognized(result.recognizedWords);
        // Continue listening
        _restartListening();
      }
    });
  }

  void _stopListening() async {
    setState(() {
      _isListening = false;
    });
    await _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isListening) // Show Start Listening button
          ElevatedButton(
            onPressed: () {
              _startListening();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFF202C33),
            ),
            child: const Text("Start Listening"),
          ),
        if (_isListening) // Show Stop Listening button
          ElevatedButton(
            onPressed: () {
              _stopListening();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFFFFFFFF),
              backgroundColor: const Color(0xFF202C33),
              padding: const EdgeInsets.all(8.0), // Smaller button
            ),
            child: const Icon(Icons.stop), // Stop icon
          ),
      ],
    );
  }
}
