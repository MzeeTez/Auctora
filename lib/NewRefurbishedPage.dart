import 'package:auctora/product_info_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewRefurbishedPage extends StatelessWidget {
  const NewRefurbishedPage({super.key});

  // --- UI Colors ---
  static const Color background = Color(0xFF101625);
  static const Color boxColor = Color(0xFF70142C);
  static const Color textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('New & Refurbished'),
        backgroundColor: boxColor,
        foregroundColor: textColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: 'New & Refurbished')
            .where('isApproved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: textColor)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: textColor));
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('No new or refurbished products found.',
                  style: TextStyle(color: textColor)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65, // Adjusted aspect ratio for new buttons
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              // Use the new, more capable widget for each grid item
              return _ProductGridItem(productDocument: products[index]);
            },
          );
        },
      ),
    );
  }
}

// --- New Stateful Widget for each Product Card ---

class _ProductGridItem extends StatefulWidget {
  final DocumentSnapshot productDocument;

  const _ProductGridItem({required this.productDocument});

  @override
  State<_ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<_ProductGridItem> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkIfInWishlist();
  }

  Future<void> _checkIfInWishlist() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final productId = widget.productDocument.id;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(productId)
          .get();
      if (mounted) {
        setState(() {
          _isInWishlist = doc.exists;
        });
      }
    }
  }

  Future<void> _toggleWishlist() async {
    User? user = _auth.currentUser;
    if (user == null) return; // Silently fail if not logged in

    final productId = widget.productDocument.id;
    final wishlistRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId);

    setState(() {
      _isInWishlist = !_isInWishlist;
    });

    if (_isInWishlist) {
      await wishlistRef.set({'productId': productId});
    } else {
      await wishlistRef.delete();
    }
  }

  Future<void> _addToCart() async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use the cart.')),
      );
      return;
    }

    final productId = widget.productDocument.id;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .set({
      'productId': productId,
      'addedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to Cart!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productDocument.data() as Map<String, dynamic>;
    final name = product['name'] ?? 'No Name';
    final price = product['price']?.toString() ?? 'N/A';
    final imageUrls = product['imageUrls'] as List?;
    final imageUrl =
    (imageUrls != null && imageUrls.isNotEmpty) ? imageUrls[0] : null;

    return Container(
      decoration: BoxDecoration(
        color: NewRefurbishedPage.boxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductInfoPage(
                            productDocument: widget.productDocument,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image,
                            size: 40, color: Colors.white38),
                      )
                          : const Icon(Icons.image_not_supported,
                          size: 40, color: Colors.white38),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isInWishlist
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: _isInWishlist ? Colors.redAccent : Colors.white,
                      iconSize: 22,
                      onPressed: _toggleWishlist,
                      tooltip: 'Add to Wishlist',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Text(
              name,
              style: const TextStyle(
                color: NewRefurbishedPage.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "₹$price",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  color: Colors.white,
                  iconSize: 22,
                  onPressed: _addToCart,
                  tooltip: 'Add to Cart',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}