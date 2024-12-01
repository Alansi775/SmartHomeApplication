import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import for Google Sign-In
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Import for Apple Sign-In
import 'sign_up_screen.dart'; // Import the signup screen
import 'main.dart'; // Import your main control screen

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String errorMessage = '';

  // Email/Password sign-in method
  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // If sign-in is successful, navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SmartHomeControl()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'An unknown error occurred.';
      });
    }
  }

  // Google Sign-In method
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in process
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      // Navigate to the next screen on successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SmartHomeControl()),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error during Google Sign-In: $e';
      });
    }
  }

  // Apple Sign-In method (not yet implemented)
  Future<void> _signInWithApple() async {
    setState(() {
      errorMessage = "Sign In with Apple not implemented yet!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: const Color(0xFFFDFFE2),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF1c231f),
                    backgroundColor: const Color(0xFFFDFFE2),
                  ),
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Navigate to the signup screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text('Don’t have an account? Sign up'),
                ),
                const Divider(height: 40, thickness: 1),
                const Text('Or Sign Up With', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.g_mobiledata),
                      color: Colors.white,
                      iconSize: 40,
                      onPressed: _signInWithGoogle,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.apple), // Apple logo icon
                      color: Colors.grey,
                      iconSize: 40,
                      onPressed: _signInWithApple, // Show the message on click
                    ),
                  ],
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
