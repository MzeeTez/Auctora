import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OldAntiquePage extends StatelessWidget {
  const OldAntiquePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF101625);
    const Color maroon = Color(0xFF70142C);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Old / Antique Products'),
        backgroundColor: maroon,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: 'Antique/Old')
        // Uncomment this line after creating the composite index
        //.orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading products:\n${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No products found.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final productData =
              products[index].data()! as Map<String, dynamic>;

              final List<dynamic>? imagesDynamic = productData['imageUrls'];
              final imageUrl = (imagesDynamic != null &&
                  imagesDynamic.isNotEmpty &&
                  imagesDynamic[0] is String)
                  ? imagesDynamic[0] as String
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
                            color: Colors.grey.shade800,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white54),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey.shade800,
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
                            productData['name'] ?? 'Unnamed Product',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            productData['description'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${productData['price']?.toString() ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white70,
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
