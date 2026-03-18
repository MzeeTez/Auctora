import 'package:auctora/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'WelcomeScreen.dart';
import 'firebase_options.dart';
import 'no_internet_page.dart'; // Import the new page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auction App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF70142c),
        scaffoldBackgroundColor: const Color(0xFFF9F4EF),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        // Handle initial state and errors
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: CircularProgressIndicator()); // Or a splash screen
        }

        // Check if 'none' is in the list of connectivity results
        final isOffline = snapshot.data!.contains(ConnectivityResult.none);

        if (isOffline) {
          return const NoInternetPage();
        }

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return const ChooseRolePage();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}