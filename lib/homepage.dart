import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'buyerpage.dart';
import 'sellerpage.dart';

class ChooseRolePage extends StatelessWidget {
  const ChooseRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color deepMaroon = const Color(0xFF70142c);
    final Color ivoryWhite = const Color(0xFFF9F4EF);
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'User';

    return Scaffold(
      backgroundColor: deepMaroon,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top cart animation
                Lottie.asset(
                  'assets/animations/login_bg.json',
                  height: 150,
                ),
                const SizedBox(height: 20),

                // Welcome Text
                Text(
                  'Welcome, $userEmail!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please choose your role to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFCEEEE),
                  ),
                ),
                const SizedBox(height: 50),

                // Buyer Button
                _HoverAnimatedButton(
                  label: 'Continue as Buyer',
                  backgroundColor: ivoryWhite,
                  textColor: deepMaroon,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyerPage()),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Seller Button
                _HoverAnimatedButton(
                  label: 'Continue as Seller',
                  backgroundColor: ivoryWhite,
                  textColor: deepMaroon,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SellerPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverAnimatedButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _HoverAnimatedButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_HoverAnimatedButton> createState() => _HoverAnimatedButtonState();
}

class _HoverAnimatedButtonState extends State<_HoverAnimatedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _isHovered ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
