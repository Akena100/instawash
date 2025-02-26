import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final List<Map<String, String>> privacySections = [
    {
      "title": "Introduction",
      "content":
          "Welcome to Insta Wash Uganda! Your privacy and trust are important to us. This Privacy Policy explains how we collect, use, share, and protect your information."
    },
    {
      "title": "Information We Collect",
      "content":
          "Personal Data, Vehicle Registration Details, Location Data, Usage Data, Photos, Device Data, Financial Data, and Push Notifications."
    },
    {
      "title": "How We Use Your Information",
      "content":
          "Account and Service Management, Order Processing, Service Enhancement, Communication and Support, Location-Based Services, Marketing and Promotions, Data Security, and Legal Compliance."
    },
    {
      "title": "Sharing of Your Information",
      "content":
          "Legal Compliance, Service Providers, Affiliates, Business Transactions, and Marketing Partners."
    },
    {
      "title": "Data Transfers",
      "content":
          "Your data may be processed at Insta Wash Uganda’s main office and other secure locations used by our third-party providers."
    },
    {
      "title": "Data Retention",
      "content":
          "We retain your information for as long as needed to fulfill the purposes outlined in this Privacy Policy or as required by law."
    },
    {
      "title": "Security of Your Information",
      "content":
          "Your data security is our priority. Payments are handled securely by Easy Pay, MTN Mobile Money, and Airtel Money."
    },
    {
      "title": "Third-Party Social Integrations",
      "content":
          "We integrate with platforms like Facebook, WhatsApp, Instagram, Twitter, LinkedIn, TikTok, and Telegram."
    },
    {
      "title": "Children’s Privacy",
      "content":
          "The Application is intended for users aged 18 and above. We do not knowingly collect information from minors."
    },
    {
      "title": "Changes to This Privacy Policy",
      "content":
          "We may update this Privacy Policy periodically. Please review it regularly for updates."
    },
    {
      "title": "Contact Us",
      "content":
          "Phone: +256 393 242 629, Email: instawashuganda@gmail.com, Website: www.instawashuganda.com"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: privacySections.map((section) {
              return ExpansionTile(
                title: Text(
                  section["title"]!,
                  style: TextStyle(fontWeight: FontWeight.bold),
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
