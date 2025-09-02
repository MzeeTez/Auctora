import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bidding_page.dart';

class LiveAuctionsPage extends StatefulWidget {
  const LiveAuctionsPage({super.key});

  @override
  _LiveAuctionsPageState createState() => _LiveAuctionsPageState();
}

class _LiveAuctionsPageState extends State<LiveAuctionsPage> {
  String _sortBy = 'endingSoonest'; // Default sort option

  // UI Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1F1F1F);
  static const Color accentRed = Color(0xFF8B1E3F);
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        foregroundColor: whiteText,
        title: const Text('Auctions', style: TextStyle(color: whiteText)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterAndSortRow(),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getAuctionsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: accentRed));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No live auctions at the moment.',
                      style: TextStyle(fontSize: 18, color: greyText),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final auctionDoc = snapshot.data!.docs[index];
                    return AuctionListItem(auctionDoc: auctionDoc);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for items',
        hintStyle: const TextStyle(color: greyText),
        prefixIcon: const Icon(Icons.search, color: greyText),
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: whiteText),
    );
  }

  Widget _buildFilterAndSortRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: whiteText),
            label: const Text('Filter', style: TextStyle(color: whiteText)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: greyText),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              filled: true,
              fillColor: cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            dropdownColor: cardDark,
            style: const TextStyle(color: whiteText),
            icon: const Icon(Icons.keyboard_arrow_down, color: whiteText),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _sortBy = newValue;
                });
              }
            },
            items: <String>['endingSoonest', 'newest', 'priceLowToHigh', 'priceHighToLow']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(_getSortOptionText(value), style: const TextStyle(color: whiteText)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getSortOptionText(String value) {
    switch (value) {
      case 'endingSoonest': return 'Ending Soonest';
      case 'newest': return 'Newest';
      case 'priceLowToHigh': return 'Price: Low to High';
      case 'priceHighToLow': return 'Price: High to Low';
      default: return 'Sort by';
    }
  }

  Stream<QuerySnapshot> _getAuctionsStream() {
    Query query = FirebaseFirestore.instance.collection('auctions').where('status', isEqualTo: 'active');

    switch (_sortBy) {
      case 'endingSoonest': query = query.orderBy('endTime'); break;
      case 'newest': query = query.orderBy('startTime', descending: true); break;
      case 'priceLowToHigh': query = query.orderBy('currentBid'); break;
      case 'priceHighToLow': query = query.orderBy('currentBid', descending: true); break;
    }
    return query.snapshots();
  }

}

class AuctionListItem extends StatefulWidget {
  final DocumentSnapshot auctionDoc;

  const AuctionListItem({super.key, required this.auctionDoc});

  @override
  State<AuctionListItem> createState() => _AuctionListItemState();
}

class _AuctionListItemState extends State<AuctionListItem> {
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
      // You can handle or log the error here
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
          color: _LiveAuctionsPageState.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80, height: 80,
                child: firstImage != null
                    ? Image.network(
                  firstImage, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40, color: _LiveAuctionsPageState.greyText),
                )
                    : const Icon(Icons.image_not_supported, size: 50, color: _LiveAuctionsPageState.greyText),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['name'] ?? 'Unknown Item',
                    style: const TextStyle(color: _LiveAuctionsPageState.whiteText, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current Bid: \$${auctionData['currentBid']?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(color: _LiveAuctionsPageState.greyText, fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatRemainingTime(_remainingTime),
                  style: TextStyle(
                    color: _remainingTime.inSeconds <= 0 ? Colors.red : _LiveAuctionsPageState.accentRed,
                    fontSize: 14, fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('remaining', style: TextStyle(color: _LiveAuctionsPageState.greyText, fontSize: 12)),
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
        color: _LiveAuctionsPageState.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const SizedBox(width: 80, height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _LiveAuctionsPageState.accentRed))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 16, color: Colors.grey.withOpacity(0.3)),
                const SizedBox(height: 8),
                Container(width: 80, height: 14, color: Colors.grey.withOpacity(0.2)),
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
        color: _LiveAuctionsPageState.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: _LiveAuctionsPageState.whiteText, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}