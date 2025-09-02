import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class BiddingPage extends StatefulWidget {
  final String auctionId;

  const BiddingPage({super.key, required this.auctionId});

  @override
  State<BiddingPage> createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage> {
  final PageController _pageController = PageController();
  final TextEditingController _bidController = TextEditingController();
  int _currentPage = 0;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _isPlacingBid = false;

  @override
  void initState() {
    super.initState();
    _startAuctionTimer();
  }

  void _startAuctionTimer() {
    final auctionRef =
    FirebaseFirestore.instance.collection('auctions').doc(widget.auctionId);
    auctionRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final endTime = (data['endTime'] as Timestamp).toDate();
        _updateTimer(endTime);
      }
    });
  }

  void _updateTimer(DateTime endTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isBefore(endTime)) {
        if (mounted) {
          setState(() {
            _timeLeft = endTime.difference(now);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _timeLeft = Duration.zero;
          });
        }
        timer.cancel();
      }
    });
  }

  Future<void> _placeBid() async {
    if (_isPlacingBid) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to place a bid.')),
      );
      return;
    }

    final amount = double.tryParse(_bidController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bid amount.')),
      );
      return;
    }

    setState(() {
      _isPlacingBid = true;
    });

    final auctionRef =
    FirebaseFirestore.instance.collection('auctions').doc(widget.auctionId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(auctionRef);
        if (!snapshot.exists) {
          throw Exception("Auction does not exist!");
        }

        final auctionData = snapshot.data() as Map<String, dynamic>;
        final currentBid = auctionData['currentBid'] ?? 0.0;

        if (amount <= currentBid) {
          throw Exception('Your bid must be higher than the current bid.');
        }

        transaction.update(auctionRef, {
          'currentBid': amount,
          'highestBidderId': user.uid,
        });

        // Optionally, add the bid to a 'bids' subcollection for history
        final bidHistoryRef = auctionRef.collection('bids').doc();
        transaction.set(bidHistoryRef, {
          'userId': user.uid,
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid placed successfully!')),
      );
      _bidController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place bid: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingBid = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bidController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .doc(widget.auctionId)
            .snapshots(),
        builder: (context, auctionSnapshot) {
          if (!auctionSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final auctionData =
          auctionSnapshot.data!.data() as Map<String, dynamic>;
          final productId = auctionData['productId'];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .get(),
            builder: (context, productSnapshot) {
              if (!productSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final productData =
              productSnapshot.data!.data() as Map<String, dynamic>;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageCarousel(
                              productData['imageUrls'] as List<dynamic>?),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productData['name'] ?? 'No Name',
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "by Swiss Timeless Co.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 24),
                                _buildTimerSection(),
                                const SizedBox(height: 24),
                                _buildBidInfo(auctionData),
                                const SizedBox(height: 16),
                                const Divider(color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  "Description",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  productData['description'] ??
                                      'No description available.',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildPlaceBidBar(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      title: const Text("Auction Details"),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<dynamic>? imageUrls) {
    imageUrls ??= [];
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                if (imageUrls!.isEmpty) {
                  return const Icon(Icons.image,
                      size: 100, color: Colors.grey);
                }
                return Image.network(imageUrls[index], fit: BoxFit.cover);
              },
            ),
          ),
          const SizedBox(height: 8),
          if (imageUrls.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_timeLeft.inHours);
    final minutes = twoDigits(_timeLeft.inMinutes.remainder(60));
    final seconds = twoDigits(_timeLeft.inSeconds.remainder(60));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text("Auction ends in", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeCard(hours, "Hours"),
              _buildTimeCard(minutes, "Minutes"),
              _buildTimeCard(seconds, "Seconds"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String time, String label) {
    return Column(
      children: [
        Text(time,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildBidInfo(Map<String, dynamic> auctionData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current Bid", style: TextStyle(color: Colors.grey)),
            Text(
              "\$${auctionData['currentBid']?.toStringAsFixed(2) ?? '0.00'}",
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        const Text("15 bids",
            style: TextStyle(color: Colors.grey)), // Placeholder
      ],
    );
  }

  Widget _buildPlaceBidBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1F1F1F),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _bidController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon:
                const Icon(Icons.attach_money, color: Colors.grey),
                hintText: "Your Bid",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isPlacingBid ? null : _placeBid,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1E3F),
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isPlacingBid
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text("Place Bid",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          )
        ],
      ),
    );
  }
}