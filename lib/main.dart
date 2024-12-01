import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Import speech_to_text package
import 'package:flutter_tts/flutter_tts.dart'; // Import flutter_tts for text-to-speech
import 'package:test_offlutter/ChatGPTCallPage.dart';
import 'sign_in_screen.dart'; // Import the SignInScreen
import 'ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1c231f),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFFDFFE2)),
        ),
      ),
      // Set SignInScreen as the initial screen
      home: const SignInScreen(),
      //home: const SmartHomeControl(),

    );
  }
}

class SmartHomeControl extends StatefulWidget {
  const SmartHomeControl({super.key});

  @override
  _SmartHomeControlState createState() => _SmartHomeControlState();
}

class _SmartHomeControlState extends State<SmartHomeControl> {
  String statusMessage = "Press the button to start voice control";
  String responseMessage = "Waiting for command...";
  Map<String, String> deviceStatus = {
    'Door': 'Closed',
    'Light': 'Turn Off',
    'Curtain': 'Closed',
    'Water': 'Closed'
  };

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('devices');
  late stt.SpeechToText _speech; // Declare the SpeechToText instance
  final FlutterTts _flutterTts = FlutterTts(); // Initialize text-to-speech

  @override
  void initState() {
    super.initState();
    _loadDeviceStatus();
    _speech = stt.SpeechToText(); // Initialize the SpeechToText object here
    _listenToGasKeyChanges(); // Start listening for gas key changes
  }


  // Load device status from Firebase
  void _loadDeviceStatus() {
    _dbRef.once().then((snapshot) {
      final data = snapshot.snapshot.value;
      if (data != null && data is Map) {
        Map<String, dynamic> devices = Map<String, dynamic>.from(data);

        setState(() {
          deviceStatus['Door'] = devices['Door'] == 1 ? "Open" : "Closed";
          deviceStatus['Light'] = devices['Light'] == 1 ? "Turn Off" : "Turn On";
          deviceStatus['Curtain'] = devices['Curtain'] == 1 ? "Open" : "Closed";
          deviceStatus['Water'] = devices['Water'] == 1 ? "Open" : "Closed";
        });
      }
    });
  }

  // Update the device status in Firebase
  void _updateDeviceStatus(String device, int newValue) {
    _dbRef.child(device).set(newValue).then((_) {
      setState(() {
        if (device == 'Light') {
          deviceStatus[device] = newValue == 1 ? "Turn Off" : "Turn On";
          responseMessage = "Light is ${newValue == 1 ? 'Turned On' : 'Turned Off'}";
        } else if (device == 'Door') {
          deviceStatus[device] = newValue == 1 ? "Open" : "Closed";
          responseMessage = "Door is now ${newValue == 1 ? 'Opened' : 'Closed'}";
        } else if(device == 'Curtain'){
          deviceStatus[device] = newValue == 1 ? "Open" : "Closed";
          responseMessage = "Curtine is now ${newValue == 1 ? 'Opened' : 'Closed'}";
        } else if(device == 'Water') {
          deviceStatus[device] = newValue == 1 ? "Open" : "Closed";
          responseMessage =
          "Water is now ${newValue == 1 ? 'Opened' : 'Closed'}";
        } else {
          deviceStatus[device] = newValue == 1 ? "Open" : "Closed";
          responseMessage = "$device is now ${newValue == 1 ? 'Opened' : 'Closed'}";
        }
      });
    });
  }

  void controlDevice(String device) {
    int newValue;
    if (device == 'Light') {
      newValue = deviceStatus[device] == "Turn Off" ? 0 : 1;
    } else {
      newValue = deviceStatus[device] == "Open" ? 0 : 1;
    }

    _updateDeviceStatus(device, newValue);
  }

  // Listen for gas key changes
  void _listenToGasKeyChanges() {
    _dbRef.child('gas').onValue.listen((event) async {
      final String gasValue = event.snapshot.value as String;
      if (gasValue.toLowerCase() == "closed") {
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.speak("Gas leaking has been discovered. and the gas pipe has been closed automatically.");
        _showGasLeakPopup("Gas Leak Detected", "Gas leaking has been discovered. and the gas pipe is closed automatically.");
      } else if (gasValue.toLowerCase() == "open") {
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.speak("Gas leaking has been stopped. and the gas pipeline is now opened.");
        _showGasLeakPopup("Gas Leak Stopped", "The gas leaking has stopped. The gas pipeline is now opened.");
      }
    });
  }

  // Show a modern-styled pop-up
  void _showGasLeakPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('                         Smart Home'),
        backgroundColor: const Color(0xFFFDFFE2),
        foregroundColor: const Color(0xFF1c231f),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display status message
            Text(statusMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Voice control button
            ElevatedButton(
              onPressed: startVoiceControl,
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF1c231f),
                backgroundColor: const Color(0xFFFDFFE2),
              ),
              child: const Text("Start Voice Control"),
            ),
            const SizedBox(height: 20),

            // Response message
            Text(responseMessage, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // Device control buttons
            _buildDeviceButton("Door", "Door"),
            _buildDeviceButton("Light", "Light"),
            _buildDeviceButton("Curtain", "Curtain"),
            _buildDeviceButton("Water", "Water"),
            const SizedBox(height: 20),

            // Row for icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Light icon
                if (deviceStatus['Light'] == "Turn Off")
                  Image.asset('assets/icons/light_icon.png', width: 70, height: 60),
                if (deviceStatus['Light'] == "Turn On")
                  Image.asset('assets/icons/light_iconoff.png', width: 70, height: 59),

                const SizedBox(width: 15), // Space between the icons

                // Door icon
                if (deviceStatus['Door'] == "Open")
                  Image.asset('assets/icons/door-lock.png', width: 70, height: 60),
                if (deviceStatus['Door'] == "Closed")
                  Image.asset('assets/icons/door-lockoff.png', width: 70, height: 59),

                const SizedBox(width: 15),

                // Curtain icon
                if (deviceStatus['Curtain'] == "Open")
                  Image.asset('assets/icons/smart-curtain.png', width: 70, height: 60),
                if (deviceStatus['Curtain'] == "Closed")
                  Image.asset('assets/icons/smart-curtainoff.png', width: 70, height: 59),

                const SizedBox(width: 15),

                // Water icon
                if (deviceStatus['Water'] == "Open")
                  Image.asset('assets/icons/water.png', width: 70, height: 55),
                if (deviceStatus['Water'] == "Closed")
                  Image.asset('assets/icons/wateroff.png', width: 70, height: 54),

                const SizedBox(width: 15),

                // Chatbot icon
// Dropdown menu for Chatbot and Home Assistant icons
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, size: 40), // You can use a different icon here
                  onSelected: (value) {
                    // Handle selection based on the value
                    if (value == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AIChat()),
                      );
                    } else if (value == 2) {
                      // Navigate to home assistant page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  ChatGPTCallPage()), // Replace with your actual HomeAssistant page
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.chat, size: 40),
                          SizedBox(width: 10),
                          Text("Chatbot"),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.home, size: 40),
                          SizedBox(width: 10),
                          Text("Home Assistant"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDeviceButton(String label, String device) {
    String buttonText = deviceStatus[device]!;

    if (device == 'Light') {
      buttonText = buttonText == 'Turn On' ? 'Turn On Light' : 'Turn Off Light';
    } else {
      buttonText = buttonText == 'Open' ? 'Close $label' : 'Open $label';
    }

    return ElevatedButton(
      onPressed: () => controlDevice(device),
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF1c231f),
        backgroundColor: const Color(0xFFFDFFE2),
      ),
      child: Text(buttonText),
    );
  }

  // Start voice control
  void startVoiceControl() async {
    setState(() {
      statusMessage = "Listening for command...";
    });

    // Start listening for voice command
    await _speech.listen(onResult: (result) {
      setState(() {
        statusMessage = result.recognizedWords;
        processVoiceCommand(result.recognizedWords);
      });
    });
  }

  // Process voice command
  void processVoiceCommand(String command) {
    // Handle voice command to control devices
    if (command.contains("open door")) {
      controlDevice('Door');
    } else if (command.contains("turn on light")) {
      controlDevice('Light');
    } else if (command.contains("open curtain")) {
      controlDevice('Curtain');
    } else if (command.contains("turn on water")) {
      controlDevice('Water');
    } else if (command.contains("close door")) {
      controlDevice('Door');
    } else if (command.contains("turn off light")) {
      controlDevice('Light');
    } else if (command.contains("close curtain")) {
      controlDevice('Curtain');
    } else if (command.contains("turn off water")) {
      controlDevice('Water');
    } else {
      setState(() {
        responseMessage = "Command not recognized. Try again!";
      });
    }
  }
}