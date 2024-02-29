import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

const apiKey = "AIzaSyDjEhPXuPuWjWkSiVSEvPpsd-Y0CFYKjCc";
const geminiEndpoint =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey";

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatUser myself = ChatUser(id: "1", firstName: "Me");
  ChatUser bot = ChatUser(id: "2", firstName: "SoulSync Buddy");
  List<ChatMessage> messages = <ChatMessage>[];
  final List<ChatUser> _typing = <ChatUser>[];

  Future<void> getdata(ChatMessage m) async {
    _typing.add(bot);
    messages.insert(0, m);
    setState(() {});
    await generateGeminiResponse(m.text);
    _typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoulSync Buddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: DashChat(
          typingUsers: _typing,
          currentUser: myself,
          onSend: (ChatMessage m) async {
            await getdata(m);
          },
          messages: messages,
          inputOptions: const InputOptions(
            alwaysShowSend: false,
            cursorStyle: CursorStyle(color: Color.fromARGB(255, 211, 210, 211)),
          ),
          messageOptions: const MessageOptions(
            currentUserContainerColor: Color.fromARGB(255, 50, 29, 47),
          ),
        ),
      ),
    );
  }

  Future<void> generateGeminiResponse(String userInput) async {
    final requestPayload = {
      "contents": [
        {"role": "user", "parts": [{"text": userInput}]}
      ],
      "generationConfig": {
        "temperature": 0,
        "topK": 1,
        "topP": 1,
        "maxOutputTokens": 1024,
        "stopSequences": [],
      },
      "safetySettings": [
        {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_LOW_AND_ABOVE"},
        {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_LOW_AND_ABOVE"},
        {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
      ],
    };

    try {
      if (await istherapy(userInput)) {
        final response = await http.post(
          Uri.parse(geminiEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestPayload),
        );

        if (response.statusCode == 200) {
          final geminiResponse = extractDesiredResponse(response.body);
          ChatMessage geminiMessage = ChatMessage(
            text: geminiResponse,
            user: bot,
            createdAt: DateTime.now(),
          );

          messages.insert(0, geminiMessage);
          setState(() {});
        } else {
          print("Gemini API request failed with status code ${response.statusCode}");
        }
      } else {
        // Handle non-therapy related input (e.g., display a message)
        print("Sorry, I can only answer therapy-related questions.");
      }
    } catch (e) {
      print("Error sending Gemini API request: $e");
    }
  }

  Future<bool> istherapy(String geminiResponse) async {
    const String apiKeys = 'AIzaSyDT8KFmc5QHXNdbHIpvQjzNlY_G1zs64MU';
    const String apiUrl = 'https://language.googleapis.com/v1/documents:analyzeEntitySentiment?key=$apiKeys';
    final Map<String, dynamic> requestBody = {
      'document': {
        'type': 'PLAIN_TEXT',
        'content': geminiResponse,
      },
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = json.decode(response.body);
        print("Ok here goes:");
        print(responseJson);
        return true;
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }

    return false;
  }

  String extractDesiredResponse(String geminiResponse) {
    try {
      Map<String, dynamic> jsonResponse = jsonDecode(geminiResponse);
      print(geminiResponse);
      if (jsonResponse.containsKey('candidates')) {
        List<dynamic> candidates = jsonResponse['candidates'];

        if (candidates.isNotEmpty) {
          Map<String, dynamic> content = candidates[0]['content'];

          if (content.containsKey('parts')) {
            List<dynamic> parts = content['parts'];

            if (parts.isNotEmpty) {
              Map<String, dynamic> textPart = parts[0];

              if (textPart.containsKey('text')) {
                String text = textPart['text'];
                text = text.replaceAll("**", "");
                return text.trim();
              }
            }
          }
        }
      }
      return "Unexpected response structure from Gemini API";
    } catch (e) {
      return "error";
    }
  }
}
