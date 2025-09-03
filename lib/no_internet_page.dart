import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundDark = Color(0xFF0F172A);
    const Color deepMaroon = Color(0xFF70142c);
    const Color whiteText = Colors.white;

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/login_bg.json', // Placeholder animation
                height: 200,
              ),
              const SizedBox(height: 32),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: whiteText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // You can add logic here to check for connection again
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepMaroon,
                  foregroundColor: whiteText,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}