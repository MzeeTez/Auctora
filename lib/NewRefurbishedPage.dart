import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewRefurbishedPage extends StatelessWidget {
  const NewRefurbishedPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF101625);
    const Color boxColor = Color(0xFF70142C);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('New / Refurbished Products'),
        backgroundColor: boxColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: 'New / Refurbished')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found.',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product['imageUrl'],
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['name'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("₹${product['price']}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
