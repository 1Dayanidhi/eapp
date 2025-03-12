import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'application_page.dart';
import 'admin_voting_page.dart';
import 'admin_announcement_page.dart';
import 'admin_nomination.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Light Pastel Blue background
      appBar: AppBar(
        title: const Text(
          "Student Election",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.account_circle, size: 30, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          },
        ),
        backgroundColor: const Color(0xFF81D4FA), // Light Sky Blue
        elevation: 0,
      ),
      body: _buildHomeScreen(),
    );
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        const SizedBox(height: 20), // Add spacing

        // ✅ Welcome Message Overlay on Image
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200, // Adjust height as needed
              width: double.infinity, // Full width
              child: Image.asset(
                'assets/videoframe_1395.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black.withOpacity(0.4), // Dark overlay for contrast
            ),
            const Positioned(
              child: Text(
                "Welcome to the Student Election!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black38,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20), // Add spacing

        // ✅ Voting-related quote
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            '"The Student Senate nurtures leadership through democratic elections, a tradition since the institution inception. Now, with the shift to an online voting system, the process is safer, easier, and more transparent. "Vote smart, vote secure - democracy at your fingertips!"',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFF333333), // Charcoal Gray
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 20), // Add spacing

        // ✅ Navigation Tabs for Admin
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              "Announcement",
              const AdminAnnouncementPage(),
              const Icon(Icons.announcement, color: Colors.white, size: 30),
            ),
            _buildNavButton(
              "Application",
              const ApplicationForm(),
              const Icon(Icons.app_registration, color: Colors.white, size: 30),
            ),
            _buildNavButton(
              "Voting",
               AdminVotingPage(), // Ensure this is properly instantiated
              const Icon(Icons.ballot, color: Colors.white, size: 30),
            ),
            _buildNavButton(
              "Nomination",
               NominationPage(), // Ensure this is properly instantiated
              const Icon(Icons.how_to_vote, color: Colors.white, size: 30),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     _buildNavButton(
        //       "Voting",
        //        AdminVotingPage(), // Ensure this is properly instantiated
        //       const Icon(Icons.ballot, color: Colors.white, size: 30),
        //     ),
        //     _buildNavButton(
        //       "Nomination",
        //        AdminNominationPage(), // Ensure this is properly instantiated
        //       const Icon(Icons.how_to_vote, color: Colors.white, size: 30),
        //     ),
        //   ],
        // ),

        const Spacer(),

        // ✅ Footer
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text(
            "Copyrights © WCC 2025 All Rights Reserved.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(String title, Widget page, Icon icon) {
    return GestureDetector(
      onTap: () => _navigateToPage(page),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF81D4FA), // Light Sky Blue Button
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}