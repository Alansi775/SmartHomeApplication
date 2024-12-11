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
        setState(() {
          errorMessage = "Sign-in was canceled by the user.";
        });
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
        errorMessage = 'Error during Google Sign-In: ${e.toString()}';
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
        backgroundColor: const Color(0xFF202C33),
        foregroundColor: const Color(0xFFD1D8E0),
      ),body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email TextField
              TextField(
                controller: _emailController,
                style: const TextStyle(
                  color: Color(0xFF202C33), // Input text color
                ),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@example.com', // Placeholder text
                  hintStyle: TextStyle(color: Color(0xFF202C33)), // Hint text color
                  labelStyle: TextStyle(color: Color(0xFF202C33)), // Label text color
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF202C33)), // Border color when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF202C33)), // Border color when focused
                  ),
                ),
                cursorColor: const Color(0xFF202C33), // Cursor color
              ),
              const SizedBox(height: 20),

              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(
                  color: Color(0xFF202C33), // Input text color
                ),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Password', // Placeholder text
                  hintStyle: TextStyle(color: Color(0xFF202C33)), // Hint text color
                  labelStyle: TextStyle(color: Color(0xFF202C33)), // Label text color
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF202C33)), // Border color when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF202C33)), // Border color when focused
                  ),
                ),
                cursorColor: const Color(0xFF202C33), // Cursor color
              ),
                const SizedBox(height: 20),

                // Log In Button
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFFFFF),
                    backgroundColor: const Color(0xFF202C33),
                  ),
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 10),

                // Navigate to SignUp Screen
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF202C33), // Set text color
                  ),
                  child: const Text('Don’t have an account? Sign up'),
                ),
                const Divider(height: 40, thickness: 1),

                // Alternative Sign-In Options
                const Text('Or Sign In With', style: TextStyle(fontSize: 16, color: Color(0xFF202C33),
                ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.g_mobiledata),
                      color: const Color(0xFF202C33),
                      iconSize: 60,
                      onPressed: _signInWithGoogle,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.apple), // Apple logo icon
                      color: const Color(0xFF202C33),
                      iconSize: 50,
                      onPressed: _signInWithApple, // Show the message on click
                    ),
                  ],
                ),
                if (errorMessage.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "Enter Correct Username And Password",
                      style: TextStyle(
                        color: Color(0xFFA02334),
                        fontWeight: FontWeight.bold, // Make the text bold
                        fontSize: 16, // Optional: Adjust font size if needed
                      ),
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
