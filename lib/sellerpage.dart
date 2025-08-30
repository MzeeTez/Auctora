import 'package:auctora/AddProductPage.dart';
import 'package:auctora/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  // --- UI Colors ---
  final Color darkBackground = const Color(0xFF0F172A);
  final Color maroon = const Color(0xFF70142C);
  final Color cardColor = const Color(0xFF1E293B);
  final Color white = Colors.white;

  // --- State Variables ---
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
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

  // --- Helper Methods ---

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

  // Show a snackbar for unimplemented features
  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature not implemented yet.')),
    );
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: darkBackground,
        appBar: AppBar(
          title: const Text('My Products'),
          backgroundColor: darkBackground,
        ),
        body: const Center(
          child: Text(
            'Please log in to see your products.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChooseRolePage()),
              (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: darkBackground,
        drawer: _buildDrawer(),
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildDashboardButtons(),
              const SizedBox(height: 24),
              Text(
                "My Listed Products",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: white,
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: darkBackground,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Row(
        children: [
          Icon(Icons.gavel, color: Colors.amber),
          SizedBox(width: 8),
          Text('AuctionHouse', style: TextStyle(color: Colors.white)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => _showNotImplemented(context),
        ),
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onPressed: () => _showNotImplemented(context),
        ),
      ],
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: darkBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: maroon),
            child: Center(
              child: Text('Seller Menu',
                  style: TextStyle(
                      color: white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          _drawerItem(Icons.home, "Home", () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const ChooseRolePage()));
          }),
          _drawerItem(
              Icons.shopping_cart, "My Orders", () => _showNotImplemented(context)),
          _drawerItem(
              Icons.favorite, "Wishlist", () => _showNotImplemented(context)),
        ],
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
        hintText: 'Search my products...',
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
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      children: [
        _dashboardButton(
          icon: Icons.add_shopping_cart,
          label: "Add Product",
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddProductPage()));
          },
        ),
        _dashboardButton(
          icon: Icons.add_circle_outline,
          label: "Create Auction",
          onTap: () => _showNotImplemented(context),
        ),
      ],
    );
  }

  Widget _dashboardButton(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: maroon,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: white, size: 36),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      // Fetches only products listed by the current user
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('userId', isEqualTo: _currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: white)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text('You have not added any products yet.',
                  style: TextStyle(color: white)));
        }

        final products = _filterProducts(snapshot.data!.docs);
        if (products.isEmpty) {
          return Center(
              child: Text('No products match your search.',
                  style: TextStyle(color: white)));
        }

        return GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final data = products[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? 'No Name';
            final isApproved = data['isApproved'] ?? false;
            final imageUrls = data['imageUrls'] as List?;
            final imageUrl = (imageUrls != null && imageUrls.isNotEmpty)
                ? imageUrls[0]
                : null;

            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                      child: imageUrl != null
                          ? Image.network(imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.white30))
                          : const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 50, color: Colors.white30)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          isApproved ? Icons.check_circle : Icons.hourglass_empty,
                          color: isApproved ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isApproved ? 'Approved' : 'Pending',
                          style: TextStyle(
                              color: isApproved ? Colors.green : Colors.orange),
                        ),
                      ],
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
}