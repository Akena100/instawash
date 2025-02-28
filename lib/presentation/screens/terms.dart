import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Ensure Get is imported for navigation
import 'package:instawash/presentation/screens/ai_chat.dart';
import 'package:instawash/presentation/widgets/insta_string_terms.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final InstaStringTerms instaStringTerms = InstaStringTerms();
  List<Map<String, String>> termsAndConditions = [];

  @override
  void initState() {
    super.initState();
    termsAndConditions = instaStringTerms.termsAndConditions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: termsAndConditions.map((section) {
              return ExpansionTile(
                title: Text(
                  section["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      section["content"]!,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      // Positioned FloatingActionButton with the "Ask me!" label
      floatingActionButton: Positioned(
        bottom: 10,
        right: 10,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => Get.to(() => ChatScreen()),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: Offset(0, 0), // Shadow position
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/robot.gif', // Replace with your GIF asset path
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: const Color.fromARGB(255, 49, 9, 114).withOpacity(0.5),
                child: Text(
                  'Ask me!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
