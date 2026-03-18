import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auctora/bidding_page.dart';

class SellerAuctionsPage extends StatefulWidget {
  const SellerAuctionsPage({super.key});

  @override
  State<SellerAuctionsPage> createState() => _SellerAuctionsPageState();
}

class _SellerAuctionsPageState extends State<SellerAuctionsPage> {
  // --- UI Colors ---
  static const Color darkBackground = Color(0xFF101625);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color white = Colors.white;
  static const Color greyText = Colors.grey;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Auctions')),
        body: const Center(child: Text('Please log in to see your auctions.', style: TextStyle(color: white))),
      );
    }

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text('My Auctions'),
        backgroundColor: darkBackground,
        foregroundColor: white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .where('sellerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have no active auctions.',
                style: TextStyle(color: greyText, fontSize: 18),
              ),
            );
          }

          final auctions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: auctions.length,
            itemBuilder: (context, index) {
              final auctionDoc = auctions[index];
              return AuctionListItem(auctionDoc: auctionDoc);
            },
          );
        },
      ),
    );
  }
}

class AuctionListItem extends StatefulWidget {
  final DocumentSnapshot auctionDoc;

  const AuctionListItem({super.key, required this.auctionDoc});

  @override
  State<AuctionListItem> createState() => _AuctionListItemState();
}

class _AuctionListItemState extends State<AuctionListItem> {
  // Define colors within this class to avoid the previous error
  static const Color cardColor = Color(0xFF1E293B);
  static const Color white = Colors.white;
  static const Color greyText = Colors.grey;

  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  DocumentSnapshot? _productDoc;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
    final auctionData = widget.auctionDoc.data() as Map<String, dynamic>?;
    if (auctionData != null && auctionData.containsKey('endTime')) {
      final endTime = (auctionData['endTime'] as Timestamp).toDate();
      _updateRemainingTime(endTime);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime(endTime));
    }
  }

  Future<void> _fetchProductData() async {
    final auctionData = widget.auctionDoc.data() as Map<String, dynamic>?;
    if (auctionData == null || auctionData['productId'] == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final productId = auctionData['productId'];
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      if (mounted) {
        setState(() {
          _productDoc = doc;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateRemainingTime(DateTime endTime) {
    if (mounted) {
      setState(() {
        final now = DateTime.now();
        _remainingTime = now.isBefore(endTime) ? endTime.difference(now) : Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatRemainingTime(Duration duration) {
    if (duration.inSeconds <= 0) return "Ended";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inDays > 0) return "${duration.inDays}d ${twoDigits(duration.inHours.remainder(24))}h";
    if (duration.inHours > 0) return "${twoDigits(duration.inHours)}h ${twoDigits(duration.inMinutes.remainder(60))}m";
    if (duration.inMinutes > 0) return "${twoDigits(duration.inMinutes)}m ${twoDigits(duration.inSeconds.remainder(60))}s";
    return "${twoDigits(duration.inSeconds)}s";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }
    final auctionData = widget.auctionDoc.data() as Map<String, dynamic>?;
    if (auctionData == null) return _buildErrorCard('Invalid auction data');
    if (_productDoc == null || !_productDoc!.exists) {
      return _buildErrorCard('Product not found for ID: ${auctionData['productId']}');
    }
    final productData = _productDoc!.data() as Map<String, dynamic>;
    final imageUrls = productData['imageUrls'] as List<dynamic>?;
    final firstImage = (imageUrls != null && imageUrls.isNotEmpty) ? imageUrls[0] : null;

    final bool isPrivate = auctionData['isPrivate'] ?? false;
    final String? auctionCode = isPrivate ? auctionData['auctionCode'] : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BiddingPage(auctionId: widget.auctionDoc.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Product Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: firstImage != null
                    ? Image.network(
                  firstImage,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: greyText),
                )
                    : const Icon(Icons.image_not_supported,
                    size: 50, color: greyText),
              ),
            ),
            const SizedBox(width: 16),
            // Product Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['name'] ?? 'Unknown Item',
                    style: const TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current Bid: \$${auctionData['currentBid']?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                        color: greyText, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (isPrivate)
                    Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('Private: $auctionCode', style: const TextStyle(color: Colors.amber)),
                      ],
                    )
                  else
                    const Row(
                      children: [
                        Icon(Icons.public, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text('Public Auction', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                ],
              ),
            ),
            // Time Remaining Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatRemainingTime(_remainingTime),
                  style: TextStyle(
                    color: _remainingTime.inSeconds <= 0
                        ? Colors.red
                        : Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text('remaining', style: TextStyle(color: greyText.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.redAccent),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 120,
                    height: 16,
                    color: Colors.grey.withOpacity(0.3)),
                const SizedBox(height: 8),
                Container(
                    width: 80,
                    height: 14,
                    color: Colors.grey.withOpacity(0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}