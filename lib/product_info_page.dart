import 'package:auctora/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductInfoPage extends StatefulWidget {
  final DocumentSnapshot productDocument;

  const ProductInfoPage({super.key, required this.productDocument});

  @override
  State<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
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
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to use the wishlist.')),
      );
      return;
    }

    final productId = widget.productDocument.id;
    final wishlistRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId);

    if (_isInWishlist) {
      await wishlistRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from wishlist.')),
      );
    } else {
      await wishlistRef.set({'productId': productId});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to wishlist.')),
      );
    }

    if (mounted) {
      setState(() {
        _isInWishlist = !_isInWishlist;
      });
    }
  }

  // --- Add to Cart Logic ---
  Future<void> _addToCart() async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to your cart.')),
      );
      return;
    }

    final productId = widget.productDocument.id;
    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    await cartRef.set({
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
    final productData = widget.productDocument.data() as Map<String, dynamic>;
    final imageUrls = productData['imageUrls'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(productData['name'] ?? 'Product Details'),
        backgroundColor: const Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: _isInWishlist ? Colors.red : Colors.white,
            ),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrls.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image,
                          color: Colors.grey, size: 50),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['name'] ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ₹${productData['price']?.toString() ?? 'N/A'}',
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productData['description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow('Category:', productData['category']),
                  _buildInfoRow('Size:', productData['size']),
                  _buildInfoRow('Color:', productData['color']),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  _buildRatingSection(),
                  const SizedBox(height: 16),
                  _buildCommentsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1E3F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _addToCart, // Connects to the Firestore function
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value?.toString() ?? 'N/A',
                  style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Ratings',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            Icon(Icons.star_half, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            const Text(
              '4.5 (125 ratings)',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildCommentItem('Alex', 'This is an amazing product! Highly recommend.'),
        const Divider(color: Colors.grey),
        _buildCommentItem('Maria', 'Great value for the price. Very satisfied.'),
        const SizedBox(height: 24),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add a comment...',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Submit Comment'),
        ),
      ],
    );
  }

  Widget _buildCommentItem(String user, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Text(user[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}