import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OldAntiquePage extends StatelessWidget {
  const OldAntiquePage({super.key});

  // --- UI Colors ---
  static const Color background = Color(0xFF101625);
  static const Color maroon = Color(0xFF70142C);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Old & Antique Products'),
        backgroundColor: maroon,
        foregroundColor: textColor, // Ensures title and icons are white
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Merged logic: Correct category, filters for approved, and sorts by creation date
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: 'Old & Antique')
            .where('isApproved', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: textColor),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: textColor),
            );
          }

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No old or antique products found.',
                style: TextStyle(color: subTextColor, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final productData = products[index].data() as Map<String, dynamic>;

              final name = productData['name'] ?? 'No Name';
              final description = productData['description'] ?? 'No description available.';
              final price = productData['price']?.toString() ?? 'N/A';
              final imageUrls = productData['imageUrls'] as List?;
              final imageUrl = (imageUrls != null && imageUrls.isNotEmpty)
                  ? imageUrls[0]
                  : null;

              return Container(
                decoration: BoxDecoration(
                  color: maroon,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black26,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white54),
                          );
                        },
                      )
                          : Container(
                        color: Colors.black26,
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white54),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(
                              color: subTextColor,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹$price',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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