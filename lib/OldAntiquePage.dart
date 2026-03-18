import 'package:auctora/product_info_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- Main Page Widget (now StatefulWidget) ---

class OldAntiquePage extends StatefulWidget {
  const OldAntiquePage({super.key});

  // --- UI Colors ---
  static const Color background = Color(0xFF101625);
  static const Color boxColor = Color(0xFF70142C);
  static const Color textColor = Colors.white;

  @override
  State<OldAntiquePage> createState() => _OldAntiquePageState();
}

class _OldAntiquePageState extends State<OldAntiquePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _sortOption = 'Newest First';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: OldAntiquePage.textColor),
        decoration: InputDecoration(
          hintText: 'Search old & antique items...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<String>(
        value: _sortOption,
        dropdownColor: OldAntiquePage.boxColor,
        style: const TextStyle(color: OldAntiquePage.textColor),
        onChanged: (String? newValue) {
          setState(() {
            _sortOption = newValue!;
          });
        },
        items: <String>['Newest First', 'Price: Low to High', 'Price: High to Low']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OldAntiquePage.background,
      appBar: AppBar(
        title: const Text('Old & Antique'),
        backgroundColor: OldAntiquePage.boxColor,
        foregroundColor: OldAntiquePage.textColor,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Align(
            alignment: Alignment.centerRight,
            child: _buildSortDropdown(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('category', isEqualTo: 'Old & Antique')
                  .where('isApproved', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: OldAntiquePage.textColor)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: OldAntiquePage.textColor));
                }

                var products = snapshot.data?.docs ?? [];

                // --- Filtering and Sorting Logic ---
                if (_searchTerm.isNotEmpty) {
                  products = products.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchTerm.toLowerCase());
                  }).toList();
                }

                products.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  if (_sortOption == 'Price: Low to High') {
                    final priceA = (dataA['price'] as num?) ?? 0.0;
                    final priceB = (dataB['price'] as num?) ?? 0.0;
                    return priceA.compareTo(priceB);
                  } else if (_sortOption == 'Price: High to Low') {
                    final priceA = (dataA['price'] as num?) ?? 0.0;
                    final priceB = (dataB['price'] as num?) ?? 0.0;
                    return priceB.compareTo(priceA);
                  } else { // Newest First (default)
                    // Note: Ensure your documents have a 'createdAt' or 'timestamp' field.
                    final timeA = (dataA['createdAt'] as Timestamp?) ?? Timestamp(0, 0);
                    final timeB = (dataB['createdAt'] as Timestamp?) ?? Timestamp(0, 0);
                    return timeB.compareTo(timeA);
                  }
                });
                // --- End Logic ---

                if (products.isEmpty) {
                  return const Center(
                    child: Text('No products match your search or filter.',
                        style: TextStyle(color: OldAntiquePage.textColor)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _ProductGridItem(productDocument: products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Stateful Widget for each Product Card (No changes needed here) ---

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
    if (user == null) return;

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
        color: OldAntiquePage.boxColor,
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
                color: OldAntiquePage.textColor,
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
                  "\$${(product['price'] as num? ?? 0.0).toStringAsFixed(2)}",
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