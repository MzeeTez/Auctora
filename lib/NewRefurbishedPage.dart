import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewRefurbishedPage extends StatelessWidget {
  const NewRefurbishedPage({super.key});

  // --- UI Colors ---
  static const Color background = Color(0xFF101625);
  static const Color boxColor = Color(0xFF70142C);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('New & Refurbished'),
        backgroundColor: boxColor,
        foregroundColor: textColor, // Ensures title and icons are white
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Correctly filters for approved products in the category
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: 'New & Refurbished')
            .where('isApproved', isEqualTo: true) // Logic from the second version
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

          // Using a GridView for a more modern layout, as suggested in the second version
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;

              final name = product['name'] ?? 'No Name';
              final price = product['price']?.toString() ?? 'N/A';
              final imageUrls = product['imageUrls'] as List?;
              final imageUrl = (imageUrls != null && imageUrls.isNotEmpty)
                  ? imageUrls[0]
                  : null;

              return Container(
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹$price",
                            style: const TextStyle(
                              color: subTextColor,
                              fontSize: 13,
                            ),
                          ),
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