import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  final String apiKey;

  ChatGPTService(this.apiKey);

  Future<String> sendMessage(String prompt) async {
    const apiUrl = "https://api.openai.com/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: json.encode({
          "model": "gpt-3.5-turbo", // Use the appropriate model
          "messages": [
            {
              "role": "system",
              "content": "You are a home assistant chatbot named SmartHome. "
                  "You can only assist with questions related to home automation, such as controlling lights, doors, curtains, "
                  "or water systems. If a user asks something unrelated, always respond with 'Sorry, I can only assist with home automation-related tasks.'"
            },
            {"role": "user", "content": prompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception("Failed to connect: ${response.body}");
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
