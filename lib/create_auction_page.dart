import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'seller_auctions_page.dart';

class CreateAuctionPage extends StatefulWidget {
  final String productId;
  final bool isPrivate;

  const CreateAuctionPage({Key? key, required this.productId, this.isPrivate = false}) : super(key: key);

  @override
  _CreateAuctionPageState createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startingBidController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool _isLoading = false;
  String _generatedCode = '';

  // --- Theme Colors ---
  static const Color darkBackground = Color(0xFF101625);
  static const Color maroon = Color(0xFF70142C);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color white = Colors.white;
  static const Color amber = Colors.amber;

  @override
  void initState() {
    super.initState();
    if (widget.isPrivate) {
      _generatedCode = _generateCode();
    }
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _createAuction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final now = Timestamp.now();
          final durationInHours = int.parse(_durationController.text);
          final endTime = Timestamp.fromMillisecondsSinceEpoch(
              now.millisecondsSinceEpoch + durationInHours * 3600 * 1000);

          await FirebaseFirestore.instance.collection('auctions').add({
            'productId': widget.productId,
            'sellerId': user.uid,
            'startingBid': double.parse(_startingBidController.text),
            'currentBid': double.parse(_startingBidController.text),
            'highestBidderId': null,
            'startTime': now,
            'endTime': endTime,
            'status': 'active',
            'isPrivate': widget.isPrivate,
            if (widget.isPrivate) 'auctionCode': _generatedCode,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Auction created successfully! ${widget.isPrivate ? 'Code: $_generatedCode' : ''}')),
          );
          Navigator.of(context)..pop()..pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create auction: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text(widget.isPrivate ? 'Create Private Auction' : 'Create Public Auction'),
        backgroundColor: darkBackground,
        foregroundColor: white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Lottie.asset(
                'assets/animations/Knock of hammer.json',
                height: 150,
                repeat: true,
              ),
              const SizedBox(height: 20),
              Text(
                'Set Up Your Auction',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextFormField(
                        controller: _startingBidController,
                        labelText: 'Starting Bid',
                        icon: Icons.monetization_on,
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        controller: _durationController,
                        labelText: 'Duration (in hours)',
                        icon: Icons.timer,
                      ),
                      if (widget.isPrivate) ...[
                        const SizedBox(height: 24),
                        _buildCodeDisplayField(),
                      ],
                      const SizedBox(height: 40),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: amber))
                          : ElevatedButton(
                        onPressed: _createAuction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroon,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Create Auction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: amber),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: amber),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildCodeDisplayField() {
    return TextFormField(
      readOnly: true,
      initialValue: _generatedCode,
      style: TextStyle(color: white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: 'Unique Auction Code',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.vpn_key, color: amber),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}