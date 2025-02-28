import 'package:flutter/material.dart';

import 'package:instawash/models/order.dart';

import 'package:instawash/presentation/screens.dart';
import 'package:instawash/presentation/screens/contact_us.dart';
import 'package:instawash/presentation/screens/faq.dart';
import 'package:instawash/presentation/screens/keys.dart';
import 'package:instawash/presentation/screens/notifications.dart';

import '../error/exceptions.dart';

sealed class AppRouter {
  static const String splash = '/';
  static const String ads = '/ads';
  static const String root = '/root';
  static const String intro = '/intro';
  static const String mealDetails = '/mealDetails';
  static const String search = '/search';
  static const String meals = '/meals';
  static const String offers = '/offers';
  static const String subscriptions = '/subscriptions';
  static const String favourites = '/favourites';
  static const String profile = '/profile';

  static const String invite = '/invite';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String contact = '/contact';
  static const String key = '/key';
  static const String privacy = '/privacy';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String selectKid = '/selectKid';
  static const String addKid = '/addKid';
  static const String addresses = '/addresses';
  static const String addAddress = '/addAddress';
  static const String checkout = '/checkout';
  static const String successfulOrder = '/successfulOrder';
  static const String orderDetails = '/orderDetails';
  static const String kidProfile = '/kidProfile';
  static const String home = '/home';
  static const String notifications = '/notifications';

  static const List<String> moreScreenTaps = [
    subscriptions,
    profile,
    about,
    terms,
    contact,
    privacy
  ];

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case notifications:
        return MaterialPageRoute(builder: (_) => NotificationsPage());
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case ads:
      case root:
        return MaterialPageRoute(builder: (_) => const RootScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());
      case offers:
      case subscriptions:
        return MaterialPageRoute(builder: (_) => const FAQPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case key:
        return MaterialPageRoute(builder: (_) => DisplayDataPage());

      case about:
        return MaterialPageRoute(builder: (_) => const AboutUs());
      case terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());

      case contact:
        return MaterialPageRoute(builder: (_) => const ContactUs());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case orderDetails:
        OrderModel orderModel = routeSettings.arguments as OrderModel;
        return MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(
                  orderModel: orderModel,
                ));

      default:
        throw const RouteException('Route not found!');
    }
  }
}
