import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Integration for payments

import 'WelcomeScreen.dart';
import 'firebase_options.dart';
import 'no_internet_page.dart';
import 'homepage.dart'; // Ensure this contains ChooseRolePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Stripe (Replace with your actual Publishable Key from Stripe Dashboard)
  Stripe.publishableKey = "pk_test_your_key_here";
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to connectivity changes to show the No Internet page dynamically
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        // Handle connectivity check
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final connectivityResults = snapshot.data ?? [ConnectivityResult.none];
        final isOffline = connectivityResults.contains(ConnectivityResult.none);

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
              // User is logged in
              return const ChooseRolePage();
            } else {
              // User is not logged in
              return const WelcomeScreen();
            }
          },
        );
      },
    );
  }
}