import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _regnoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _passwordVisible = false;

  final RegExp _emailRegEx = RegExp(r'^[0-9]{2}[a-z]{3}[0-9]{2}@wcc\.edu\.in$', caseSensitive: false);
  final RegExp _passwordRegEx = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])(?=.*\d)[A-Za-z\d!@#\$&*~]{8,}$');
  final RegExp _regnoRegEx = RegExp(r'^[0-9]{2}[a-zA-Z]{3}[0-9]{2}$', caseSensitive: false); 
  final RegExp _phoneRegEx = RegExp(r'^\d{10}$');  

  String? _passwordErrorMessage;

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final regno = _regnoController.text.trim();  
    final phone = _phoneController.text.trim();

    // Check if all fields are filled
    if (email.isEmpty || password.isEmpty || username.isEmpty || regno.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Check if Regno in Email and Regno field match
    final emailRegnoPart = email.split('@')[0];
    if (emailRegnoPart.toLowerCase() != regno.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Regno in Email and Regno field must match')),
      );
      return;
    }

    // Validate email with regular expression
    if (!_emailRegEx.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email format. Please use the college mail id')),
      );
      return;
    }

    // Validate password
    if (password.length < 8) {
      _passwordErrorMessage = "Password must be at least 8 characters long";
    } else if (!password.contains(RegExp(r'[A-Z]'))) {
      _passwordErrorMessage = "Password must contain at least one uppercase letter";
    } else if (!password.contains(RegExp(r'[!@#\$&*~]'))) {
      _passwordErrorMessage = "Password must contain at least one special character";
    } else if (!password.contains(RegExp(r'\d'))) {
      _passwordErrorMessage = "Password must contain at least one digit";
    } else {
      _passwordErrorMessage = null;  // Password is valid
    }

    // If there are any password validation errors
    if (_passwordErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_passwordErrorMessage!)),
      );
      return;
    }

    // Validate Regno and Phone number
    if (!_regnoRegEx.hasMatch(regno)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Regno format.')),
      );
      return;
    }
    if (!_phoneRegEx.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number must be exactly 10 digits')),
      );
      return;
    }

    // Firebase signup logic
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the UID of the user
      String uid = userCredential.user!.uid;

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'regno': regno,
        'phone': phone,
        'email': email,
      });

      // If signup is successful, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully Signed Up. Login for confirmation')),
      );

      // Navigate to login page after successful signup
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase error
      String message = 'Something went wrong. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use. Please Login';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1F5FE), // Light Pastel Blue background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0, left: 16.0),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF81D4FA), // Light Sky Blue for Heading
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // College Logo Placeholder
              SizedBox(
                height: 150,
                width: 150,
                child: Image.asset('assets/wcc-removebg-preview.png'), // College logo
              ),
              const SizedBox(height: 20),

              // Vision Statement
              Text(
                '"Empowering Minds, Shaping Futures"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF333333), // Charcoal Gray for Text
                ),
              ),
              const SizedBox(height: 32),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white, // White background for form fields
                ),
              ),
              const SizedBox(height: 16),

              // Regno Field
              TextFormField(
                controller: _regnoController,
                decoration: InputDecoration(
                  labelText: 'Regno',
                  hintText: 'Enter your regno',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.card_membership),
                  filled: true,
                  fillColor: Colors.white, // White background for form fields
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email ID',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white, // White background for form fields
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white, // White background for form fields
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.white, // White background for form fields
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),

              // Sign Up Button
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF81D4FA), // Light Sky Blue Button
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Redirect to Login Button
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: Color(0xFF4FC3F7), // Slightly darker blue for text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
