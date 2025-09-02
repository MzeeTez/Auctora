import 'package:auctora/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'WelcomeScreen.dart';
import 'firebase_options.dart';

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
      home: AuthWrapper(), // 👈 Replace with this widget
    );
  }
}

/// This widget decides which screen to show based on login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 👤 User is signed in
      return const ChooseRolePage(); // 🔁 Replace with your real post-login screen
    } else {
      // 🙅‍♂️ Not signed in
      return const WelcomeScreen();
    }
  }
}
