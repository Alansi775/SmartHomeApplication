import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_database/firebase_database.dart';

class GasLeakListener {
  final DatabaseReference _dbRef;
  final FlutterTts _flutterTts;
  final BuildContext context; // Add this line

  GasLeakListener(this._dbRef, this._flutterTts, this.context) { // Update this line
    _listenToGasKeyChanges();
  }

  // Listen for gas key changes
  void _listenToGasKeyChanges() {
    _dbRef.child('gas').onValue.listen((event) async {
      final String gasValue = event.snapshot.value as String;
      if (gasValue.toLowerCase() == "detected") {
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.speak("Gas leaking has been discovered. and the gas pipe has been closed automatically.");
        // Pass the context here
        _showGasLeakPopup(context, "Gas Leak Detected", "Gas leaking has been discovered. and the gas pipe is closed automatically.");
      } else if (gasValue.toLowerCase() == "open") {
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.speak("Gas leaking has been stopped. and the gas pipeline is now opened.");
        // Pass the context here
        _showGasLeakPopup(context, "Gas Leak Stopped", "The gas leaking has stopped. The gas pipeline is now opened.");
      }
    });
  }

  // Show a modern-styled pop-up
  void _showGasLeakPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF202C33),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
             color: Color(0xFFFFFFFF),
             fontSize: 16
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ],
        );
      },
    );
  }
}
