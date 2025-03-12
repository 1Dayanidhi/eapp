import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'application_page.dart';
import 'Nomination_page.dart';
import 'announcement_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String studentId = "12345"; // Example student ID (You may fetch it from Firebase Auth)

  Future<bool> checkEligibility(String studentId) async {
    // Simulate fetching eligibility status from a database
    await Future.delayed(Duration(seconds: 1)); // Simulating a network/database call
    // Example: Assume students with even IDs are eligible
    return int.tryParse(studentId) != null && int.parse(studentId) % 2 == 0;
  }

  Future<void> _checkEligibilityForApplication(Widget page) async {
    bool isEligible = await checkEligibility(studentId);
    
    if (isEligible) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are not eligible to apply for the post.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1F5FE), // Light Pastel Blue background
      appBar: AppBar(
        title: const Text(
          "Student Election",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.account_circle, size: 30, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfilePage()),
            );
          },
        ),
        backgroundColor: Color(0xFF81D4FA), // Light Sky Blue
        elevation: 0,
      ),
      body: _buildHomeScreen(),
    );
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        SizedBox(height: 20),

        // Welcome Message Overlay on Image
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200, // Adjust height as needed
              width: double.infinity, // Full width
              child: Image.asset(
                'assets/videoframe_1395.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black.withOpacity(0.4), // Dark overlay for contrast
            ),
            Positioned(
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

        // Voting related quote
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '"The Student Senate nurtures leadership through democratic elections, a tradition since the institution inception. Now, with the shift to an online voting system, The process is safer, easier, and more transparent. "Vote smart, vote secure - democracy at your fingertips!"',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFF333333), // Charcoal Gray
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 20),

        // Navigation Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              "Announcement",
              AnnouncementsPage(),
              Icon(Icons.announcement, color: Colors.white, size: 30),
            ),
            _buildApplicationButton(
              "Application",
              ApplicationForm(),
              Icon(Icons.app_registration, color: Colors.white, size: 30),
            ),
            _buildNavButton(
              "Nomination",
              NominationForm(),
              Icon(Icons.ballot, color: Colors.white, size: 30),
            ),
          ],
        ),
        const Spacer(),

        // Footer
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Color(0xFF81D4FA), // Light Sky Blue Button
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationButton(String title, Widget page, Icon icon) {
    return GestureDetector(
      onTap: () => _checkEligibilityForApplication(page),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Color(0xFF81D4FA), // Light Sky Blue Button
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}