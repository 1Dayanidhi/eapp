import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login.dart'; // Import your Login Page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to Login Page after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1F5FE),  // Pastel Blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Larger College Logo with Fade-in Animation
            Image.asset(
              'assets/logo-removebg-preview.png',  // Ensure this file exists in your assets folder
              width: 200,  // Made logo bigger
              height: 200, 
            ).animate().fade(duration: 1500.ms),

            SizedBox(height: 20),

            // Welcome Text with Scale Animation
            Text(
              "Welcome Student Election App",
              style: TextStyle(
                fontSize: 24,  // Increased font size for better visibility
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ).animate().scale(duration: 1000.ms),

            SizedBox(height: 10),

            // "Your Vote Your Right" Text with a different font style
            Text(
              "Your Vote Your Right",
              style: TextStyle(
                fontSize: 18,  // Slightly smaller font size
                fontWeight: FontWeight.w600,  // Slightly bolder
                fontFamily: 'Times New Roman',  // Changed the font family to 'Roboto', you can replace it with another font
                color: Colors.blueGrey,
              ),
            ).animate().fade(duration: 1200.ms),
          ],
        ),
      ),
    );
  }
}