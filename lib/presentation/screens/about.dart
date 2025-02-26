import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpansionTile(
                title: "Background",
                content:
                    "Insta Wash Uganda is a licensed, professional cleaning company offering a wide range of mobile and on-site sanitation and maintenance services across Uganda. Specialties include vehicle, residential, commercial, industrial, and health facility cleaning, as well as garbage management, pest control, and more.\n\nWith over five years of experience, we bring reliable, high-quality, and convenient cleaning solutions directly to clients via our mobile app and advanced cleaning technologies. Our team of 100+ trained professionals is equipped with modern tools to meet and exceed customer satisfaction.\n\n'With Insta Wash Uganda, one call cleans it all.'",
              ),
              _buildExpansionTile(
                title: "Vision",
                content:
                    "To lead in exceptional hygiene and cleaning services nationwide.",
              ),
              _buildExpansionTile(
                title: "Mission",
                content:
                    "To provide convenient, proficient, and top-quality cleaning services that meet growing client demands across various sectors.",
              ),
              _buildExpansionTile(
                title: "Our Purpose",
                content:
                    "At Insta Wash Uganda, our purpose is to provide reliable, high-quality cleaning services for homes, businesses, government, and private clients, ensuring exceptional value and sustainable care for their assets. As Uganda’s only all-in-one mobile and commercial cleaning provider, we strive to exceed expectations and deliver premium results that guarantee customer satisfaction.",
              ),
              _buildExpansionTile(
                title: "Our Aim",
                content:
                    "With a focus on home care, mobile auto, and commercial cleaning, we are committed to going beyond customer expectations by combining expertise, experience, and advanced technology to achieve outstanding results.",
              ),
              _buildExpansionTile(
                title: "Values",
                content:
                    "\u2022 Professionalism: Our dedicated team takes pride in delivering solutions with integrity and passion for all your cleaning needs.\n\n\u2022 Customer Satisfaction: We aim for enduring partnerships by maintaining the highest standards of quality and convenience.\n\n\u2022 Time & Convenience: We value our clients' time, bringing our services directly to them for seamless, accessible cleaning.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile({required String title, required String content}) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            content,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
