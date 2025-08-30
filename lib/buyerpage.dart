import 'package:auctora/OldAntiquePage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'homepage.dart';
import 'NewRefurbishedPage.dart';
import 'live_auctions_page.dart'; // Import the new live auctions page

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
        appBar: _buildAppBar(),
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

  AppBar _buildAppBar() {
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
          Spacer(),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: null, // Disabled for now
              color: whiteText),
          IconButton(
              icon: Icon(Icons.notifications_none),
              onPressed: null, // Disabled for now
              color: whiteText),
          IconButton(
              icon: Icon(Icons.person_outline),
              onPressed: null, // Disabled for now
              color: whiteText),
        ],
      ),
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
          const _DrawerItem(icon: Icons.shopping_cart, label: "My Orders"),
          const _DrawerItem(icon: Icons.favorite_border, label: "Wishlist"),
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
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6, // Placeholder
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image, size: 60, color: Colors.grey),
                  SizedBox(height: 8),
                  Text("Vintage Item",
                      style: TextStyle(
                          color: whiteText, fontWeight: FontWeight.bold)),
                  Text("Current Bid: \$150",
                      style: TextStyle(color: accentYellow)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DrawerItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {}, // Placeholder
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