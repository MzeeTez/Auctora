import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<DocumentSnapshot>>? _cartStream;

  @override
  void initState() {
    super.initState();
    User? user = _auth.currentUser;
    if (user != null) {
      _cartStream = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .snapshots()
          .asyncMap((cartSnapshot) async {
        List<String> productIds = cartSnapshot.docs.map((doc) => doc.id).toList();
        if (productIds.isEmpty) {
          return [];
        }
        QuerySnapshot productSnapshots = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: productIds)
            .get();
        return productSnapshots.docs;
      });
    }
  }

  void _removeFromCart(String productId) {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(productId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundDark = Color(0xFF0D1117);
    const Color cardDark = Color(0xFF161B22);
    const Color highlightRed = Color(0xFF8B1E3F);
    const Color accentYellow = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: cardDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _cartStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          var cartItems = snapshot.data!;
          double totalCost = 0.0;
          for (var item in cartItems) {
            final data = item.data() as Map<String, dynamic>;
            final price = data['price'] ?? data['startingPrice'] ?? 0;
            totalCost += (price is String ? double.tryParse(price) ?? 0.0 : price.toDouble());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var product = cartItems[index].data() as Map<String, dynamic>;
                    var productId = cartItems[index].id;
                    String imageUrl = (product['imageUrls'] as List?)?.isNotEmpty ?? false
                        ? product['imageUrls'][0]
                        : 'https://via.placeholder.com/150';
                    final price = product['price'] ?? product['startingPrice'] ?? '0';

                    return Card(
                      color: cardDark,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(product['name'] ?? 'No Name', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('₹$price', style: const TextStyle(color: accentYellow)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                          onPressed: () => _removeFromCart(productId),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildTotalSection(totalCost, highlightRed),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalSection(double totalCost, Color buttonColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(top: BorderSide(color: Colors.black26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('₹${totalCost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: totalCost > 0 ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutPage()),
              );
            } : null,
            child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}