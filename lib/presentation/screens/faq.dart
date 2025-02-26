import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frequently Asked Questions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FAQSection(
              title: 'General Information',
              faqs: [
                FAQ(
                    question: 'What is Insta Wash Uganda?',
                    answer:
                        'Insta Wash Uganda is a professional cleaning service provider offering mobile and on-site cleaning solutions for homes, offices, vehicles, and more.'),
                FAQ(
                    question: 'What makes Insta Wash Uganda different?',
                    answer:
                        'Insta Wash Uganda combines convenience, professionalism, and eco-friendly cleaning practices. With our app, you can schedule, manage, and pay for cleaning services seamlessly.')
              ],
            ),
            FAQSection(
              title: 'Getting Started',
              faqs: [
                FAQ(
                    question: 'How do I download the Insta Wash Uganda app?',
                    answer:
                        'You can download the app from the Google Play Store for Android or the Apple App Store for iOS.'),
                FAQ(
                    question: 'How do I create an account?',
                    answer:
                        'Open the app, click on "Sign Up," and provide your name, phone number, email, and password. You can also sign up using your Google or Facebook account.'),
                FAQ(
                    question: 'Do I need to verify my account?',
                    answer:
                        'Yes, you will receive a verification code via SMS or email to activate your account.')
              ],
            ),
            FAQSection(
              title: 'Services',
              faqs: [
                FAQ(
                    question:
                        'What cleaning services are offered through the app?',
                    answer:
                        'Insta Wash Uganda provides:\n\n- Vehicle cleaning (interior and exterior)\n- Home cleaning (general, deep cleaning, and specialized services)\n- Office cleaning\n- Carpet and upholstery cleaning\n- Laundry and dry cleaning'),
                FAQ(
                    question: 'Can I customize my cleaning request?',
                    answer:
                        'Yes, during the booking process, you can specify your needs, such as areas to focus on, preferred cleaning agents, and additional services.'),
                FAQ(
                    question: 'Do you offer recurring cleaning services?',
                    answer:
                        'Yes, you can schedule weekly, bi-weekly, or monthly cleaning services via the app.')
              ],
            ),
            FAQSection(
              title: 'Booking',
              faqs: [
                FAQ(
                    question: 'How do I book a cleaning service?',
                    answer:
                        '1. Open the app and log in.\n2. Select the service you need.\n3. Choose the date, time, and location.\n4. Confirm your booking.'),
                FAQ(
                    question: 'Can I reschedule or cancel my booking?',
                    answer:
                        'Yes, go to "My Bookings" and select the booking you want to modify. You can reschedule or cancel within the policy\'s timeframe.'),
                FAQ(
                    question: 'How far in advance can I book a service?',
                    answer: 'You can book services up to 30 days in advance.')
              ],
            ),
            FAQSection(
              title: 'Payments',
              faqs: [
                FAQ(
                    question: 'What payment methods are accepted?',
                    answer:
                        'We accept mobile money, credit/debit cards, and cash on delivery.'),
                FAQ(
                    question: 'Is payment made before or after the service?',
                    answer:
                        'You can choose to pay upfront via the app or upon completion of the service.'),
                FAQ(
                    question: 'Are there any additional fees?',
                    answer:
                        'No hidden fees! The price quoted during booking is final unless additional services are added later.')
              ],
            ),
            FAQSection(
              title: 'Quality and Safety',
              faqs: [
                FAQ(
                    question: 'Are the cleaning staff trained?',
                    answer:
                        'Yes, all our staff undergo rigorous training to ensure they meet professional cleaning standards.'),
                FAQ(
                    question: 'Do you use safe cleaning products?',
                    answer:
                        'Absolutely. We use eco-friendly and non-toxic cleaning agents that are safe for children, pets, and the environment.'),
                FAQ(
                    question:
                        'What happens if I am not satisfied with the service?',
                    answer:
                        'If you\'re unhappy, contact customer support within 24 hours, and we\'ll address your concerns.')
              ],
            ),
            FAQSection(
              title: 'User Features',
              faqs: [
                FAQ(
                    question: 'Can I track the cleaner\'s arrival?',
                    answer:
                        'Yes, the app provides real-time tracking of your assigned cleaner.'),
                FAQ(
                    question: 'Can I save my favorite cleaners?',
                    answer:
                        'Yes, after a service, you can rate and save your preferred cleaners for future bookings.'),
                FAQ(
                    question: 'Does the app offer promotions or discounts?',
                    answer:
                        'Yes, check the "Promotions or packaged offers" section for available offers and discounts.')
              ],
            ),
            FAQSection(
              title: 'Customer Support',
              faqs: [
                FAQ(
                    question: 'How can I contact customer support?',
                    answer:
                        'You can reach us via the in-app chat, email, or call us directly through the app.'),
                FAQ(
                    question: 'What are your customer support hours?',
                    answer:
                        'Our support team is available from 8:00 AM to 8:00 PM, Monday to Sunday.')
              ],
            ),
            FAQSection(
              title: 'Technical Issues',
              faqs: [
                FAQ(
                    question: 'What should I do if the app crashes or freezes?',
                    answer:
                        'Ensure you have the latest version of the app installed. Restart your device, and if the issue persists, contact support.'),
                FAQ(
                    question: 'How do I update my app?',
                    answer:
                        'Visit the Google Play Store or Apple App Store, search for "Insta Wash Uganda," and click "Update" if available.'),
                FAQ(
                    question:
                        'Can I use the app without an internet connection?',
                    answer:
                        'You need an internet connection to book, manage, or pay for our services.')
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});
}

class FAQSection extends StatelessWidget {
  final String title;
  final List<FAQ> faqs;

  const FAQSection({super.key, required this.title, required this.faqs});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: faqs.map((faq) {
        return ListTile(
          title:
              Text(faq.question, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(faq.answer),
        );
      }).toList(),
    );
  }
}
