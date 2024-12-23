import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextControl extends StatefulWidget {
  final Function(String) onCommandRecognized;

  const SpeechToTextControl({Key? key, required this.onCommandRecognized}) : super(key: key);

  @override
  _SpeechToTextControlState createState() => _SpeechToTextControlState();
}

class _SpeechToTextControlState extends State<SpeechToTextControl> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Slower animation duration
      vsync: this,
    )..repeat(reverse: true); // Repeat the animation

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smoother curve
    ));

    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _controller.repeat(reverse: true); // Start pulsing animation
      await _speech.listen(onResult: (result) {
        if (result.hasConfidenceRating && result.confidence > 0.5) {
          widget.onCommandRecognized(result.recognizedWords);
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
        _restartListening();
      }
    });
  }

  void _stopListening() async {
    _controller.stop(); // Stop the pulsing animation
    setState(() {
      _isListening = false;
    });
    await _speech.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: ScaleTransition(
            scale: _animation,
            child: GestureDetector(
              onTap: () {
                if (!_isListening) {
                  _startListening();
                } else {
                  _stopListening();
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF202C33),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(15), // Circle size
                child: _isListening
                    ? const Icon(
                  Icons.square_rounded, // Use a different icon for the non-listening state
                  color: Color(0xFFFFFFFF),
                  size: 35, // Icon size
                )
                    : Image.asset(
                  'assets/icons/home.png', // Your custom icon
                  color: Colors.white, // Change color if needed
                  width: 35, // Icon width
                  height: 35, // Icon height
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
