import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:instawash/core/constants/assets.dart';
import 'package:instawash/core/constants/colors.dart';
import 'package:instawash/presentation/screens/ai_chat.dart';
import 'package:instawash/presentation/widgets/intawash_location.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  void _scaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.secondaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Contact Us',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          children: [
            Container(
              height: 150,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              margin: const EdgeInsets.all(20),
              child: SvgPicture.asset(
                AppAssets.customerService,
                colorFilter:
                    const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
              ),
            ),
            ListTile(
              onTap: () {
                _makePhoneCall('+256414530988');
              },
              leading: FaIcon(
                FontAwesomeIcons.phone,
                size: size.width * 0.09,
                color: Colors.yellow,
              ),
              title: Text(
                '0414530988',
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () async {
                Uri uri =
                    Uri(scheme: 'mailto', path: 'instawashuganda@gmail.com');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.message,
                    size: size.width * 0.09,
                    color: Colors.red,
                  )),
              title: Text(
                'instawashuganda@gmail.com',
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () async {
                Uri uri = Uri.parse(
                    'https://twitter.com/InstaWash?t=3Q96I9JR98HgA69gisdXdA&s=09');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.twitter,
                    size: size.width * 0.09,
                    color: Colors.blue,
                  )),
              title: Text(
                'Twitter',
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () async {
                Uri uri = Uri.parse('https://wa.me/message/YJYOIMRS4RB4A1');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: size.width * 0.09,
                    color: Colors.green,
                  )),
              title: Text(
                'Whatsapp',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.white,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () async {
                Uri uri = Uri.parse(
                    'https://www.facebook.com/instawashuganda256?mibextid=LQQJ4d');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.facebook,
                    size: size.width * 0.09,
                    color: Colors.blue,
                  )),
              title: Text(
                'Facebook',
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () async {
                Uri uri = Uri.parse(
                    'https://www.instagram.com/instawashuganda?igsh=NnRhb2U2bng5OWI2');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.squareInstagram,
                    size: size.width * 0.09,
                    color: Colors.purpleAccent,
                  )),
              title: Text(
                'Instagram',
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () async {
                Uri uri = Uri.parse(
                    'https://www.linkedin.com/company/instawashuganda/');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              leading: FaIcon(
                FontAwesomeIcons.linkedin,
                size: size.width * 0.09,
                color: Colors.white,
              ),
              title: Text(
                'LinkedIn',
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () async {
                Uri uri = Uri.parse(
                    'https://www.tiktok.com/@insta.wash.uganda?_t=8qoK6CvXqNS&_r=1');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              leading: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.tiktok,
                    size: size.width * 0.09,
                    color: Colors.white,
                  )),
              title: Text(
                'TikTok',
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            ListTile(
              onTap: () async {
                Uri uri = Uri.parse('https://www.instawashuganda.com/');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.globe,
                    size: size.width * 0.09,
                    color: Colors.blueAccent,
                  )),
              title: Text(
                'www.instawashuganda.com',
                style:
                    TextStyle(fontSize: size.width * 0.04, color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
            ),
            SizedBox(
              height: 25,
            ),
            Divider(),
            Container(
              margin: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Instawash Location',
                      style: TextStyle(fontSize: size.width * 0.05),
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          Get.to(() => SpecificLocationMap());
                        },
                        icon: FaIcon(FontAwesomeIcons.expand)),
                  ),
                  Expanded(child: SpecificLocationMap()),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => ChatScreen());
          },
          backgroundColor: Colors.black,
          child: Image.asset('assets/robot.gif'),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  void openWhatsapp(BuildContext context) async {
    // Your custom wa.me link
    String whatsappUrl = "https://wa.me/message/YJYOIMRS4RB4A1";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      _showSnackbar(context, "WhatsApp is not installed");
    }
  }

// Helper function to show a Snackbar
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
