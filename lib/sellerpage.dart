import 'package:auctora/AddProductPage.dart';
import 'package:auctora/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'homepage.dart'; // Make sure this is correct
import 'AddProductPage.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final Color darkBackground = const Color(0xFF0F172A);
  final Color maroon = const Color(0xFF70142C);
  final Color white = Colors.white;

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter products by search term
  List<QueryDocumentSnapshot> _filterProducts(
      List<QueryDocumentSnapshot> products) {
    if (_searchTerm.isEmpty) return products;
    return products.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();
      return name.contains(_searchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // simple pop back to ChooseRolePage
        return false;
      },
      child: Scaffold(
        backgroundColor: darkBackground,
        drawer: Drawer(
          backgroundColor: darkBackground,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: maroon),
                child: Center(
                  child: Text(
                    'Seller Menu',
                    style: TextStyle(
                      color: white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _drawerItem(Icons.home, "Home", () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ChooseRolePage()),
                );
              }),
              _drawerItem(Icons.shopping_cart, "My Orders", () {
                Navigator.pop(context);
                // TODO: Implement navigation to My Orders page
                _showNotImplemented(context);
              }),
              _drawerItem(Icons.favorite, "Wishlist", () {
                Navigator.pop(context);
                // TODO: Implement navigation to Wishlist page
                _showNotImplemented(context);
              }),
              _drawerItem(Icons.notifications, "Notifications", () {
                Navigator.pop(context);
                // TODO: Implement navigation to Notifications page
                _showNotImplemented(context);
              }),
              _drawerItem(Icons.receipt_long, "Transactions", () {
                Navigator.pop(context);
                // TODO: Implement navigation to Transactions page
                _showNotImplemented(context);
              }),
              _drawerItem(Icons.local_shipping, "Track Delivery", () {
                Navigator.pop(context);
                // TODO: Implement navigation to Track Delivery page
                _showNotImplemented(context);
              }),
              _drawerItem(Icons.support_agent, "Support / Chat Seller", () {
                Navigator.pop(context);
                // TODO: Implement navigation to Support / Chat Seller page
                _showNotImplemented(context);
              }),
              _drawerItem(Icons.settings, "Settings", () {
                Navigator.pop(context);
                // TODO: Implement navigation to Settings page
                _showNotImplemented(context);
              }),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: darkBackground,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            children: const [
              Icon(Icons.gavel, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'AuctionHouse',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                // TODO: Notifications action
                _showNotImplemented(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                // TODO: Profile action
                _showNotImplemented(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildDashboardButtons(),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Products I Listed",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildProductGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: white),
      title: Text(title, style: TextStyle(color: white)),
      onTap: onTap,
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildDashboardButtons() {
    final List<Map<String, dynamic>> buttons = [
      {"icon": Icons.add_shopping_cart, "label": "Add Products"},
      {"icon": Icons.add_circle_outline, "label": "Create Auction"},
      {"icon": Icons.live_tv, "label": "Check my live Auction"},
      {"icon": Icons.inventory_2, "label": "Product I listed"},
    ];

    return GridView.builder(
      itemCount: buttons.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            final label = buttons[index]['label'];

            if (label == "Add Products") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );
            } else if (label == "Create Auction") {
              _showNotImplemented(context); // Replace when you build the page
            } else if (label == "Check my live Auction") {
              _showNotImplemented(context); // Replace when ready
            } else if (label == "Product I listed") {
              _showNotImplemented(context); // Replace when you make the page
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: maroon,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(buttons[index]['icon'], color: white, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    buttons[index]['label'],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading products', style: TextStyle(color: white)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No products listed yet.', style: TextStyle(color: white)));
        }

        final products = _filterProducts(snapshot.data!.docs);
        if (products.isEmpty) {
          return Center(child: Text('No products match your search.', style: TextStyle(color: white)));
        }

        return GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final product = products[index].data() as Map<String, dynamic>;
            final name = product['name'] ?? 'Unnamed product';
            final bid = product['bid'] ?? 'N/A';
            final imageUrl = product['imageUrl'] as String?;
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 50, color: Colors.white30),
                      )
                          : const Icon(Icons.image_not_supported, size: 50, color: Colors.white30),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Current Bid: $bid",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature not implemented yet.')),
    );
  }
}
