import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryProductsPage extends StatelessWidget {
  final String category;

  const CategoryProductsPage({super.key, required this.category});

  static const Color bgColor = Color(0xFF101625);
  static const Color boxColor = Color(0xFF70142C);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: boxColor,
        title: Text(
          '$category Items',
          style: const TextStyle(color: textColor),
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading products',
                style: TextStyle(color: textColor),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: boxColor),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No products found for this category',
                style: TextStyle(color: textColor),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>?;

              if (data == null) return const SizedBox();

              final title = data['title'] ?? 'No Title';
              final price = data['price'] ?? 'N/A';
              final imageUrls = data['imageUrls'];

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
                        child: (imageUrls != null &&
                            imageUrls is List &&
                            imageUrls.isNotEmpty)
                            ? Image.network(
                          imageUrls[0],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                            : const Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Price: ₹$price',
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
