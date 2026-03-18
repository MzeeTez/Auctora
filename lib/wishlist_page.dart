import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Corrected
import 'package:firebase_auth/firebase_auth.dart'; // Corrected
import 'product_info_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<DocumentSnapshot>>? _wishlistStream;

  @override
  void initState() {
    super.initState();
    User? user = _auth.currentUser;
    if (user != null) {
      _wishlistStream = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .snapshots()
          .asyncMap((snapshot) async {
        List<String> productIds = snapshot.docs.map((doc) => doc.id).toList();
        if (productIds.isEmpty) {
          return [];
        }
        // Fetch product details for each product ID
        QuerySnapshot productSnapshots = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: productIds)
            .get();
        return productSnapshots.docs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundDark = Color(0xFF0D1117);
    const Color cardDark = Color(0xFF161B22);
    const Color highlightRed = Color(0xFF8B1E3F);

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(color: Colors.white)),
        backgroundColor: cardDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _wishlistStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Your wishlist is empty.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          var wishlistItems = snapshot.data!;

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              var productDocument = wishlistItems[index];
              var product = productDocument.data() as Map<String, dynamic>;
              var productId = productDocument.id;
              String imageUrl = (product['imageUrls'] as List?)?.isNotEmpty ?? false
                  ? product['imageUrls'][0]
                  : 'https://via.placeholder.com/150';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // We need to pass the DocumentSnapshot to the updated ProductInfoPage
                      builder: (context) => ProductInfoPage(productDocument: productDocument),
                    ),
                  );
                },
                child: Card(
                  color: cardDark,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'No Name',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$${product['price'] ?? product['startingPrice']}',
                                style: const TextStyle(color: highlightRed, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white70),
                          onPressed: () async {
                            User? user = _auth.currentUser;
                            if (user != null) {
                              await _firestore
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('wishlist')
                                  .doc(productId)
                                  .delete();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}