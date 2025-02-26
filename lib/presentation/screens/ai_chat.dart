import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:instawash/presentation/widgets/insta_privacy_string.dart';
import 'package:instawash/presentation/widgets/insta_string_profile.dart';
import 'package:instawash/presentation/widgets/insta_string_terms.dart';

const apiKey = 'AIzaSyDEM4cnJPwuFnzEZZu5rZrHpwxYxM-fPeY';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  final InstaStringProfile instaStringProfile = InstaStringProfile();
  final InstaStringTerms instaStringTerms = InstaStringTerms();
  final InstaPrivacyString instaPrivacyString = InstaPrivacyString();

  String bound = '';
  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    fetch();
    super.initState();

    bound = instaStringProfile.getString +
        json.encode(instaStringTerms.termsAndConditions) +
        jsonEncode(instaPrivacyString.privacySections);

    intro();
  }

  intro() {
    _messages.add(ChatMessage(
      text:
          "Hello $name! I am Insta Wash, here to help you with Insta Wash's cleaning services. How can I assist you today?",
      isUserMessage: false,
    ));
  }

  String name = '';

  fetch() async {
    QuerySnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .get();
    setState(() {
      name = userDoc.docs[0]['fullName'];
    });
  }

  void _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    final question = '''
Using this information: "$bound", answer the following question in a natural, conversational 
manner as if you were talking to a human being.  
- Include emotions, greetings, and natural interactions in your response.  
- Always relate your answer back to Insta Wash and its cleaning services when relevant.  
- If the question completely diverts from Insta Wash and its services, politely refuse to 
answer while keeping the conversation friendly and engaging and very short and state your main purpose.  
- Keep the response lively and engaging, ensuring it feels like a real conversation.  
Now, here's the question: "$prompt".
''';

    setState(() {
      _messages.add(ChatMessage(
        text: prompt,
        isUserMessage: true,
      ));
    });

    _controller.clear();

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    final content = [Content.text(question)];
    final response = await model.generateContent(content);
    final finalResponse = _sanitizeResponse(response.text);

    setState(() {
      _messages.add(ChatMessage(
        text: finalResponse ?? "I'm sorry, I couldn't generate a response.",
        isUserMessage: false,
      ));
    });
  }

  String? _sanitizeResponse(String? text) {
    return text?.replaceAll('*', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with InstaBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your prompt...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft;
    final backgroundColor =
        message.isUserMessage ? Colors.blue : Colors.grey.shade200;
    final textColor = message.isUserMessage ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: alignment,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
