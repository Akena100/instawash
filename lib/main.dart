import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/core.dart';
import 'package:awesome_notifications/awesome_notifications.dart'; // Import awesome_notifications

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          "AIzaSyCkiUtYT7BRJrZ7lL6RlRghPSPDdm7dhjw", // Firebase configuration
      projectId: "insta-wash01",
      authDomain: "insta-wash01.firebaseapp.com",
      storageBucket: "insta-wash01.appspot.com",
      messagingSenderId: "397876177539",
      appId: "1:397876177539:android:4bc15dcafdbe25a430c9b6",
      measurementId: "G-PEVXGV7NXB",
    ),
  );
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: false,
  );
  debugPrint("📩 Background Message: ${message.notification?.title}");

  // Display notification using awesome_notifications
  if (message.notification != null) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.notification.hashCode,
        channelKey: 'basic_channel', // Ensure this matches your channel key
        title: message.notification?.title,
        body: message.notification?.body,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCkiUtYT7BRJrZ7lL6RlRghPSPDdm7dhjw",
      projectId: "insta-wash01",
      authDomain: "insta-wash01.firebaseapp.com",
      storageBucket: "insta-wash01.appspot.com",
      messagingSenderId: "397876177539",
      appId: "1:397876177539:android:4bc15dcafdbe25a430c9b6",
      measurementId: "G-PEVXGV7NXB",
    ),
  );

  Bloc.observer = NibblesBlocObserver();
  AwesomeNotifications().cancelAll();

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await requestLocationPermission();
  await _setupFirebaseMessaging();
  await _setupAwesomeNotifications(); // Initialize Awesome Notifications

  runApp(const MyApp());
}

/// Setup Firebase Messaging
Future<void> _setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('✅ Notification permission granted.');
  } else {
    debugPrint('❌ Notification permission denied.');
    return;
  }

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("📩 Foreground Message: ${message.notification?.title}");

    if (message.notification != null) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: message.notification.hashCode,
          channelKey: 'basic_channel',
          title: message.notification?.title,
          body: message.notification?.body,
        ),
      );
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    status = await Permission.location.request();
  }

  if (status.isDenied || status.isPermanentlyDenied) {
    debugPrint('❌ Location permission denied');
  } else {
    debugPrint('✅ Location permission granted');
  }
}

Future<void> _setupAwesomeNotifications() async {
  await AwesomeNotifications().initialize(
    'resource://drawable/logo',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.deepPurple,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        defaultPrivacy: NotificationPrivacy.Private,
      )
    ],
  );

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (ReceivedAction action) async {
      await _deleteNotification(action.id);
      await _decreaseBadgeCount();
      return Future.value();
    },
    onDismissActionReceivedMethod: (ReceivedAction action) async {
      await _deleteNotification(action.id);
      await _decreaseBadgeCount();
      return Future.value();
    },
  );
}

Future<void> _deleteNotification(int? notificationId) async {
  if (notificationId != null) {
    await AwesomeNotifications()
        .cancel(notificationId); // Removes the notification from the system
  }
}

Future<void> _decreaseBadgeCount() async {
  int currentBadgeCount = await AwesomeNotifications().getGlobalBadgeCounter();
  int newBadgeCount = currentBadgeCount > 0 ? currentBadgeCount - 1 : 0;
  await AwesomeNotifications().setGlobalBadgeCounter(newBadgeCount);
}
