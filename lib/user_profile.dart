import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Variables to store user data
  String username = '';
  String email = '';
  String phone = '';
  String regno = '';
  bool isEditing = false;

  // Controllers to manage the editable fields
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // Firebase user object
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Function to get user data from Firebase
  Future<void> _getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? '';
          email = userDoc['email'] ?? '';
          phone = userDoc['phone'] ?? '';
          regno = userDoc['regno'] ?? '';

          // Set initial values to controllers
          usernameController.text = username;
          phoneController.text = phone;
        });
      } else {
        print("No user document found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load user data'),
      ));
    }
  }

  // Function to save changes to Firestore
  Future<void> _saveChanges() async {
    String newUsername = usernameController.text.trim();
    String newPhone = phoneController.text.trim();

    // Validate inputs
    if (newUsername.isEmpty || newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Username and Phone Number cannot be empty.'),
      ));
      return;
    }

    try {
      // Update the Firestore document with the new values
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'username': newUsername,
        'phone': newPhone,
      });

      // Update local state
      setState(() {
        username = newUsername;
        phone = newPhone;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update profile. Please try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1F5FE), // Light Pastel Blue background
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Color(0xFF81D4FA), // Light Sky Blue
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Circle avatar with the first letter of the username
              CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF4FC3F7),
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'A',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Username field
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  enabled: isEditing,
                  labelStyle: TextStyle(color: Color(0xFF4FC3F7)), // Light Sky Blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF81D4FA)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              // Email field (display only, not editable)
              TextField(
                controller: TextEditingController(text: email),
                decoration: InputDecoration(
                  labelText: 'Email',
                  enabled: false,
                  labelStyle: TextStyle(color: Color(0xFF4FC3F7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF81D4FA)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              // Phone number field
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  enabled: isEditing,
                  labelStyle: TextStyle(color: Color(0xFF4FC3F7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF81D4FA)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              // Regno field (display only, not editable)
              TextField(
                controller: TextEditingController(text: regno),
                decoration: InputDecoration(
                  labelText: 'Reg No',
                  enabled: false,
                  labelStyle: TextStyle(color: Color(0xFF4FC3F7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF81D4FA)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 32),

              // Edit button to enable/disable fields
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    // Save changes when editing is true
                    _saveChanges();
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2, // Adding slight elevation for button
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Edit Profile',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}