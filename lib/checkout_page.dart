import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'package:http:http.dart' as http;

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  const CheckoutPage({super.key, required this.totalAmount});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => makePayment(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Payment Logic
  Future<void> makePayment() async {
    try {
      // 1. Create Payment Intent on your server/Stripe
      paymentIntent = await createPaymentIntent(
          (widget.totalAmount * 100).toInt().toString(), 'USD');

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Auctora Auction',
        ),
      );

      // 3. Display Payment Sheet
      displayPaymentSheet();
    } catch (e) {
      debugPrint("Payment Error: $e");
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful!")),
      );
      paymentIntent = null;
      // Navigate back to home or success screen
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Payment Canceled: $e");
    }
  }

  // Create Payment Intent (Usually handled by your backend)
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer your_stripe_secret_key_here',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('Error charging user: ${err.toString()}');
    }
  }
}