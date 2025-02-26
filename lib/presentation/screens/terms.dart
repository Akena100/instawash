import 'package:flutter/material.dart';
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
    );
  }
}
