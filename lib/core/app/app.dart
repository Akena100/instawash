import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:instawash/application/application.dart';
import 'package:instawash/connectivity/no_internet_connection_page.dart';
import 'package:instawash/connectivity/service.dart';

import 'package:instawash/repositories/repositories.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core.dart';

import 'package:get/get.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isConnected = true;

  Future<void> _checkInternetConnection() async {
    bool isConnected = await InternetConnectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    requestLocationPermission();
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

  @override
  Widget build(BuildContext context) {
    return !_isConnected
        ? NoInternetConnectionPage()
        : MultiRepositoryProvider(
            providers: [
              RepositoryProvider(
                create: (context) => AuthRepository(
                    firebaseAuth: FirebaseAuth.instance,
                    firestore: FirebaseFirestore.instance),
              ),
              RepositoryProvider(
                create: (context) => UserRepository(
                    firebaseFirestore: FirebaseFirestore.instance),
              ),
            ],
            child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => AuthBloc(
                      authRepository: context.read<AuthRepository>(),
                    )..add(InitializeAuthEvent()),
                  ),
                  BlocProvider(
                    lazy: false,
                    create: (context) => UserBloc(
                      authBloc: context.read<AuthBloc>(),
                      userRepository: context.read<UserRepository>(),
                    )..add(StartUserEvent()),
                  ),
                ],
                child: const GetMaterialApp(
                  title: 'Insta Wash',
                  debugShowCheckedModeBanner: false,
                  onGenerateRoute: AppRouter.onGenerateRoute,
                  initialRoute: AppRouter.splash,
                )),
          );
  }
}
