import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAuctionPage extends StatefulWidget {
  final String productId;

  const CreateAuctionPage({Key? key, required this.productId}) : super(key: key);

  @override
  _CreateAuctionPageState createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startingBidController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool _isLoading = false;

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
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Auction created successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create auction: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Auction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _startingBidController,
                decoration: const InputDecoration(labelText: 'Starting Bid'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a starting bid';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration:
                const InputDecoration(labelText: 'Duration (in hours)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _createAuction,
                  child: const Text('Create Auction'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}