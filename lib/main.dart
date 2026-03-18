import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'WelcomeScreen.dart';
import 'firebase_options.dart';
import 'no_internet_page.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Stripe
  Stripe.publishableKey = "pk_test_51TCQdVRukTzh2MHjHBMzwh2V6zUd3PBB9aU0jhJAHtzWXJOVHkK7MPTYAmVM4rtdmTfL6IDqEY7FPOYsOW00auSu00dP35y0T3";
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auctora Auction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF70142c),
        scaffoldBackgroundColor: const Color(0xFFF9F4EF),
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF70142c),
          primary: const Color(0xFF70142c),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  List<ConnectivityResult> _connectivityResults = [ConnectivityResult.wifi];

  @override
  void initState() {
    super.initState();
    // Check initial connectivity immediately to prevent the infinite loading bug
    Connectivity().checkConnectivity().then((result) {
      if (mounted) setState(() => _connectivityResults = result);
    });

    // Listen to changes afterwards
    Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) setState(() => _connectivityResults = result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = _connectivityResults.contains(ConnectivityResult.none);

    if (isOffline) {
      return const NoInternetPage();
    }

    // Handle Authentication state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authSnapshot.hasData) {
          return const ChooseRolePage();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}