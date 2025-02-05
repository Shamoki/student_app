import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  // Function to send a POST request to the backend login API
  Future<void> login(BuildContext context, String email, String password) async {
    var url = Uri.parse('http://localhost:5000/api/auth/login');
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      if (email.isEmpty || password.isEmpty) {
        _showErrorDialog(context, 'Login failed', 'Email and Password are required.');
        return;
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _showErrorDialog(context, 'Login failed', 'Please enter a valid email address.');
        return;
      }

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var userId = responseData['userId'];
        var token = responseData['token'];
        var username = responseData['user']['username'];
        var email = responseData['user']['email'];
        var interestsSet = responseData['user']['interestsSet']; // ✅ Fetch interestsSet

        // Store token, userId, username, email, and interestsSet in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        await prefs.setString('token', token);
        await prefs.setString('username', username); 
        await prefs.setString('email', email);        
        await prefs.setBool('interestsSet', interestsSet); // ✅ Save interestsSet status

        // Debugging to confirm data storage
        print('Login Successful');
        print('UserId: $userId');
        print('Token: $token');
        print('Username: $username');
        print('Email: $email');
        print('Interests Set: $interestsSet');

        // Clear input fields
        emailController.clear();
        passwordController.clear();

        // Navigate based on whether interests are set
        if (interestsSet) {
          Navigator.pushReplacementNamed(context, '/home', arguments: userId);
        } else {
          Navigator.pushReplacementNamed(context, '/interests', arguments: userId);
        }
      } else {
        // Display error message
        var errorMsg = jsonDecode(response.body)['msg'] ?? 'Login failed';
        _showErrorDialog(context, 'Login failed', errorMsg);
      }
    } catch (e) {
      _showErrorDialog(context, 'Login failed', 'An error occurred during login. $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
    }
  }

  // Function to display an error dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 60.0),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Enter your credentials to login",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 3, left: 3),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable button while loading
                      : () {
                          login(
                            context,
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
              const Center(child: Text("Or")),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
