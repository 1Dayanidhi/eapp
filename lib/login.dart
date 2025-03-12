import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'admin_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  // Student email format (xxabcxx@wcc.edu.in)
  final RegExp _studentEmailRegEx = RegExp(r'^[0-9]{2}[a-z]{3}[0-9]{2}@wcc\.edu\.in$');

  // Admin email format (admin@wcc.edu.in)
  final RegExp _adminEmailRegEx = RegExp(r'^admin@wcc\.edu\.in$');

  // Password validation
  final RegExp _passwordRegEx = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]{8,}$');

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Validate email (either student or admin)
    if (!_studentEmailRegEx.hasMatch(email) && !_adminEmailRegEx.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format. Use college email or admin email.')),
      );
      return;
    }

    // Validate password
    if (!_passwordRegEx.hasMatch(password)) {
      String errorMessage = 'Password is invalid.';
      if (password.length < 8) {
        errorMessage = 'Password must be at least 8 characters long.';
      } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
        errorMessage = 'Password must contain at least one uppercase letter.';
      } else if (!RegExp(r'(?=.*[!@#\$&*~])').hasMatch(password)) {
        errorMessage = 'Password must contain at least one special character.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully Logged In. Welcome!')),
      );

      // Redirect based on email type
      if (_adminEmailRegEx.hasMatch(email)) {
        // Redirect admin to AdminHomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      } else {
        // Redirect student to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Redirecting to Sign Up.')),
      );
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Light Blue background
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
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF81D4FA), // Light Sky Blue Heading
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                height: 150,
                width: 150,
                child: Image.asset('assets/wcc-removebg-preview.png'), // College Logo
              ),
              const SizedBox(height: 20),

              Text(
                '"Empowering Minds, Shaping Futures"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF333333), // Charcoal Gray Text
                ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock),
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
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81D4FA), // Light Sky Blue Button
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  "Don't have an account? Sign up",
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