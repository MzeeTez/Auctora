import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart'; // Make sure this exists

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const Color primary = Color(0xFF007BFF);   // Blue
  static const Color dark = Color(0xFF2C2C2C);      // Dark Gray
  static const Color accent = Color(0xFFF8C471);    // Amber/Gold Accent
  static const Color light = Color(0xFFF5F5F5);     // Light Background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🛠️ Lottie Auction Animation
              Lottie.asset(
                'assets/animations/Knock of hammer.json'
                , // ✅ Rename the file properly
                height: 250,
                repeat: true,
              ),
              const SizedBox(height: 20),

              // 🏷️ App Title
              const Text(
                "Auctora",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: dark,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // 📝 Subtitle
              Text(
                "Place your bids. Win big. Real-time auctions made easy.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 🔘 Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color(0xFF70142c),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "GET STARTED",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
