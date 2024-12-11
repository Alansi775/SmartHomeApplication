import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:test_offlutter/ChatGPTCallPage.dart';
import 'speech_to_text.dart'; // Import the updated speech to text file
import 'sign_in_screen.dart';
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
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF202C33)),
        ),
      ),
      home: const SignInScreen(),
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
  final FlutterTts _flutterTts = FlutterTts(); // Initialize text-to-speech
  bool _isListening = false; // Define the listening state

  @override
  void initState() {
    super.initState();
    _loadDeviceStatus();
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
        } else {
          deviceStatus[device] = newValue == 1 ? "Open" : "Closed";
          responseMessage = "$device is now ${newValue == 1 ? 'Opened' : 'Closed'}";
        }
      });
    });
  }

  void controlDevice(String command) {
    String device;
    int newValue;

    if (command.endsWith('On')) {
      device = command.split(' ')[0]; // Get device name
      newValue = 1; // Turn on
    } else if (command.endsWith('Off')) {
      device = command.split(' ')[0]; // Get device name
      newValue = 0; // Turn off
    } else {
      return; // Invalid command
    }

    _updateDeviceStatus(device, newValue);
  }


  void processVoiceCommand(String command) {
    setState(() {
      statusMessage = "Command Received: $command"; // Feedback to user
    });

    // Normalize the command to lower case for easier matching
    String normalizedCommand = command.toLowerCase();

    // Check for various phrases to control devices
    if (normalizedCommand.contains("open the door") ||
        normalizedCommand.contains("hey home open the door") ||
        normalizedCommand.contains("hey home open the door please") ||
        normalizedCommand.contains("make the home opened") ||
        normalizedCommand.contains("let me in") ||
        normalizedCommand.contains("please open the door") ||
        normalizedCommand.contains("can you open the door") ||
        normalizedCommand.contains("open the door please")) {
      controlDevice('Door On');
    } else if (normalizedCommand.contains("close the door") ||
        normalizedCommand.contains("please close the door") ||
        normalizedCommand.contains("can you close the door") ||
        normalizedCommand.contains("shut the door") ||
        normalizedCommand.contains("close the door please")) {
      controlDevice('Door Off');
    } else if (normalizedCommand.contains("turn on the light") ||
        normalizedCommand.contains("light on") ||
        normalizedCommand.contains("please turn on the light") ||
        normalizedCommand.contains("can you turn on the light") ||
        normalizedCommand.contains("switch on the light")) {
      controlDevice('Light On');
    } else if (normalizedCommand.contains("turn off the light") ||
        normalizedCommand.contains("light off") ||
        normalizedCommand.contains("please turn off the light") ||
        normalizedCommand.contains("can you turn off the light") ||
        normalizedCommand.contains("switch off the light")) {
      controlDevice('Light Off');
    } else if (normalizedCommand.contains("open the curtain") ||
        normalizedCommand.contains("pull the curtain") ||
        normalizedCommand.contains("please open the curtain") ||
        normalizedCommand.contains("can you open the curtain")) {
      controlDevice('Curtain On');
    } else if (normalizedCommand.contains("close the curtain") ||
        normalizedCommand.contains("shut the curtain") ||
        normalizedCommand.contains("please close the curtain") ||
        normalizedCommand.contains("can you close the curtain")) {
      controlDevice('Curtain Off');
    } else if (normalizedCommand.contains("open the water") ||
        normalizedCommand.contains("turn on the water") ||
        normalizedCommand.contains("please open the water") ||
        normalizedCommand.contains("can you open the water")) {
      controlDevice('Water On');
    } else if (normalizedCommand.contains("close the water") ||
        normalizedCommand.contains("turn off the water") ||
        normalizedCommand.contains("please close the water") ||
        normalizedCommand.contains("can you close the water")) {
      controlDevice('Water Off');
    } else {
      setState(() {
        statusMessage = 'Command not recognized. Please try again.';
      });
    }

    // Restart listening for the next command
    if (_isListening) {
      _startListening();
    }
  }


  // Start listening for commands
  void _startListening() {
    setState(() {
      _isListening = true;
    });
  }

  // Stop listening for commands
  void _stopListening() {
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Smart Home')),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF202C33),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(statusMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            SpeechToTextControl(
              onCommandRecognized: (command) {
                processVoiceCommand(command);
              },
            ),
            const SizedBox(height: 20),
            Text(responseMessage, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildDeviceButton("Door", "Door"),
            _buildDeviceButton("Light", "Light"),
            _buildDeviceButton("Curtain", "Curtain"),
            _buildDeviceButton("Water", "Water"),
            const SizedBox(height: 20),
            _buildDeviceStatusIcons(),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF202C33),
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                "Smart Home",
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text(
                "Logout",
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF202C33),
        selectedItemColor: const Color(0xFFB7B597),
        unselectedItemColor: const Color(0xFFFFFFFF),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.home_max), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_rounded), label: 'Home Assistance'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) => AIChat()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatGPTCallPage()));
              break;
          }
        },
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
        foregroundColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFF202C33),
      ),
      child: Text(buttonText),
    );
  }

  Widget _buildDeviceStatusIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (deviceStatus['Light'] == "Turn Off")
          Image.asset('assets/icons/light_iconoff.png', width: 70, height: 60),
        if (deviceStatus['Light'] == "Turn On")
          Image.asset('assets/icons/light_icon.png', width: 70, height: 59),
        const SizedBox(width: 15),
        if (deviceStatus['Door'] == "Open")
          Image.asset('assets/icons/door-lockoff.png', width: 70, height: 60),
        if (deviceStatus['Door'] == "Closed")
          Image.asset('assets/icons/door-lock.png', width: 70, height: 59),
        const SizedBox(width: 15),
        if (deviceStatus['Curtain'] == "Open")
          Image.asset('assets/icons/smart-curtainoff.png', width: 70, height: 60),
        if (deviceStatus['Curtain'] == "Closed")
          Image.asset('assets/icons/smart-curtain.png', width: 70, height: 59),
        const SizedBox(width: 15),
        if (deviceStatus['Water'] == "Open")
          Image.asset('assets/icons/wateroff.png', width: 70, height: 55),
        if (deviceStatus['Water'] == "Closed")
          Image.asset('assets/icons/water.png', width: 70, height: 54),
      ],
    );
  }
}
