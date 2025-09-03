import 'package:auctora/OldAntiquePage.dart';
import 'package:auctora/cart_page.dart';
import 'package:auctora/product_info_page.dart';
import 'package:auctora/wishlist_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'homepage.dart';
import 'NewRefurbishedPage.dart';
import 'live_auctions_page.dart';

class BuyerPage extends StatelessWidget {
  const BuyerPage({super.key});

  // --- UI Colors and Styles ---
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color cardDark = Color(0xFF161B22);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color highlightRed = Color(0xFF8B1E3F);
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChooseRolePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: backgroundDark,
        appBar: _buildAppBar(context),
        drawer: _buildDrawer(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Lottie.asset('assets/animations/buyer.json',
                      height: 150)),
              const SizedBox(height: 16),
              _buildPromoBanner(),
              const SizedBox(height: 24),
              const Text("Categories",
                  style: TextStyle(
                      color: whiteText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildCategoryGrid(context),
              const SizedBox(height: 24),
              const Text("Recommended for You",
                  style: TextStyle(
                      color: whiteText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildRecommendedList(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: cardDark,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        children: const [
          Icon(Icons.gavel, color: accentYellow),
          SizedBox(width: 8),
          Text("Auction",
              style:
              TextStyle(color: whiteText, fontWeight: FontWeight.bold)),
          Text("House",
              style: TextStyle(
                  color: accentYellow, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            color: whiteText),
        IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            color: whiteText),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: cardDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: highlightRed),
            child: Text("Menu",
                style: TextStyle(color: whiteText, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text("Home", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChooseRolePage()),
              );
            },
          ),
          const _DrawerItem(icon: Icons.shopping_cart, label: "My Orders", onTap: null,),
          _DrawerItem(
            icon: Icons.favorite_border,
            label: "Wishlist",
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistPage())
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlightRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hot Auction Deals!",
                    style: TextStyle(
                        color: whiteText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Don't miss out on today’s featured items.",
                    style: TextStyle(color: greyText)),
              ],
            ),
          ),
          Icon(Icons.local_fire_department, color: accentYellow, size: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _CategoryCard(
          title: "New & Refurbished",
          icon: Icons.new_releases,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewRefurbishedPage()),
            );
          },
        ),
        _CategoryCard(
          title: "Old & Antique",
          icon: Icons.history_edu,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OldAntiquePage()),
            );
          },
        ),
        _CategoryCard(
            title: "Live Auctions",
            icon: Icons.gavel,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveAuctionsPage()),
              );
            }),
        _CategoryCard(title: "Customized", icon: Icons.build, onTap: () {}),
      ],
    );
  }

  Widget _buildRecommendedList() {
    return SizedBox(
      height: 220,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('isApproved', isEqualTo: true)
              .limit(6)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final products = snapshot.data!.docs;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _RecommendedItem(productDocument: products[index]);
              },
            );
          }),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // Added onTap callback

  const _DrawerItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap, // Use the provided callback
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: BuyerPage.accentYellow),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _RecommendedItem extends StatelessWidget {
  final DocumentSnapshot productDocument;

  const _RecommendedItem({required this.productDocument});

  @override
  Widget build(BuildContext context) {
    final productData = productDocument.data() as Map<String, dynamic>;
    final imageUrls = productData['imageUrls'] as List?;
    final imageUrl =
    (imageUrls != null && imageUrls.isNotEmpty) ? imageUrls[0] : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductInfoPage(productDocument: productDocument),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: BuyerPage.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl != null
                    ? Image.network(imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 50))
                    : const Center(
                    child: Icon(Icons.image_not_supported, size: 50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                productData['name'] ?? 'No Name',
                style: const TextStyle(
                  color: BuyerPage.whiteText,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '₹${productData['price']}',
                style: const TextStyle(color: BuyerPage.accentYellow),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}