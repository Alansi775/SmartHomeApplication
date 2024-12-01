import 'package:flutter/material.dart';
import 'chatgpt_service.dart';

class AIChat extends StatefulWidget {
  @override
  _AIChatState createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> {
  final ChatGPTService chatGPT = ChatGPTService("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");
  final TextEditingController _controller = TextEditingController();
  String _response = "";

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      _response = "Loading...";
    });

    final reply = await chatGPT.sendMessage(userMessage);

    setState(() {
      _response = reply;
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Home AI Assistant"),
        backgroundColor: const Color(0xFFFDFFE2),
        foregroundColor: const Color(0xFF1c231f),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Ask Your Home Assistance",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text("Send"),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF1c231f),
                backgroundColor: const Color(0xFFFDFFE2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
