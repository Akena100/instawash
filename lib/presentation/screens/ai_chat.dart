import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final InstaStringProfile instaStringProfile = InstaStringProfile();
  final InstaStringTerms instaStringTerms = InstaStringTerms();
  final InstaPrivacyString instaPrivacyString = InstaPrivacyString();

  String bound = '';
  User user = FirebaseAuth.instance.currentUser!;
  String name = '';
  String collectionJsonString = '';

  @override
  void initState() {
    super.initState();
    fetch();
    _fetchCollectionData();

    bound = instaStringProfile.getString +
        json.encode(instaStringTerms.termsAndConditions) +
        jsonEncode(instaPrivacyString.privacySections) +
        collectionJsonString;
  }

  // Fetch and store the entire collection as a JSON string
  Future<void> _fetchCollectionData() async {
    try {
      // Fetch all documents from the "images" collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('subServices') // Your collection name
          .get();

      // Convert each document to a map and store in a list
      List<Map<String, dynamic>> allDocuments = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      // Encode the entire collection as a JSON string
      collectionJsonString = jsonEncode(allDocuments);

      // print(
      //     "Collection as JSON: $collectionJsonString"); // Print the JSON string
    } catch (e) {
      //print("Error fetching collection: $e");
    }
  }

  String userJsonString = '';
  fetch() async {
    QuerySnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .get();

    if (userDoc.docs.isNotEmpty) {
      setState(() {
        name = userDoc.docs[0]['fullName'];
      });
      // JSON encode the entire document as a string
      userJsonString = jsonEncode(userDoc.docs[0].data());
      debugPrint("User Document as JSON: $userJsonString");
      intro();
    }
  }

  intro() {
    _addMessage(
      "Hello $name! I am here to help you with Insta Wash's cleaning services. How can I assist you today?",
      false,
    );
  }

  void _addMessage(String text, bool isUserMessage) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUserMessage: isUserMessage));
    });

    // Scroll to the bottom after adding a message
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  void _addAnimatedMessage(String text) {
    setState(() {
      _messages
          .add(ChatMessage(text: text, isUserMessage: false, isAnimated: true));
    });

    // Scroll to the bottom after adding an animated message
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100), // Adjust the scroll speed
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    _addMessage(prompt, true);

    // Clear the text field and dismiss the keyboard
    _controller.clear();
    _focusNode.unfocus();

    String appBookingProcess = """
1.Select Your Service:

On the Home Screen, browse our services and choose the one that suits your needs.
On the next page, select a specific service under the category you've chosen.
Choose your preferred date and time for the service.
For car-related services, provide car details.
Then you can add extra services you want to add.
After reviewing, click Book to proceed.
Enter Your Location:

You'll be directed to a map page, where you can either search or use your current location.
Click Continue to move on to the next step.
Checkout:

On the Checkout Page, review all your booking details.
Depending on the service, you’ll either be prompted to Request a Quotation or Pay.
For Payment: Choose between MTN Mobile Money or Airtel Money by entering a valid mobile number with available funds.
Important: Do not leave the app before completing the payment process. If you exit before, you risk losing the payment as your order won’t be received.
For Quotation: You’ll be contacted for further details, followed by a site visit. Once all details are agreed upon, a quotation will be provided.

2. Popular Services:

On the Home Screen, you’ll also find a section for Popular Services showcasing the most-used sub-services.
Follow the same steps as outlined in Step 1 to complete your booking.

3.Search for Services:

The Search feature lets you find specific sub-services easily.
After selecting the service, follow the same simple steps as Step 1 to finalize your booking.
""";

    final question = '''
Using the following information: "$bound", craft a response as if you were having a friendly, engaging conversation with a real person.  

- Start with a warm greeting and maintain a natural, conversational tone.
- Refer to "$appBookingProcess" if user asks about booking then rest can come from "$bound"
- Be brief if question is not detailed 
- Add emotions, enthusiasm, and relatable interactions to make the response feel lively.  
- Always connect your answer back to Insta Wash and its cleaning services whenever relevant.  
- If the question completely strays from Insta Wash and its services, politely steer the conversation back while keeping it brief, friendly, and engaging. Clearly state that your primary purpose is to discuss Insta Wash.  
- Ensure the response is friendly,engaging, and feels like a real conversation rather than a robotic reply.
- Remember the person is using the app now so do not mention it unless the criteria of the question demands
- Dont talk about images, just get a way around such a question
- You can also leverage the useful parts of this personal user(this is the current user's personal data) data: '$userJsonString' where necessessary, leave coded or hidden info.

Now, here’s the question: "$prompt".  
''';

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    final content = [Content.text(question)];
    final response = await model.generateContent(content);
    final finalResponse = _sanitizeResponse(response.text);

    // Check if the generated response is already in the list to prevent repetition
    if (!_messages.any((message) => message.text == finalResponse)) {
      _addAnimatedMessage(
          finalResponse ?? "I'm sorry, I couldn't generate a response.");
    }
  }

  String? _sanitizeResponse(String? text) {
    return text?.replaceAll('*', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: const Text('Insta AI'),
          leading: FaIcon(FontAwesomeIcons.robot),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final alignment = message.isUserMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft;
                final backgroundColor =
                    message.isUserMessage ? Colors.blue : Colors.grey.shade200;
                final textColor =
                    message.isUserMessage ? Colors.white : Colors.black;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: alignment,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: message.isAnimated
                          ? AnimatedTextKit(
                              isRepeatingAnimation: false,
                              onFinished: () {
                                // Scroll after animation finishes
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  _scrollToBottom();
                                });
                              },
                              animatedTexts: [
                                TyperAnimatedText(
                                  message.text,
                                  textStyle: TextStyle(color: textColor),
                                  speed: const Duration(milliseconds: 50),
                                ),
                              ],
                            )
                          : Text(
                              message.text,
                              style: TextStyle(color: textColor),
                            ),
                    ),
                  ),
                );
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
                    focusNode: _focusNode,
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
  final bool isAnimated;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    this.isAnimated = false,
  });
}
