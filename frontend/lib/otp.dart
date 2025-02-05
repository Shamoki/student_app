import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart'; // Import Lottie

class OTPVerificationPage extends StatefulWidget {
  final String email;

  const OTPVerificationPage({required this.email, super.key});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false; // Show loading indicator during verification
  bool isResending = false; // Show loading indicator during OTP resending

  Future<void> verifyOTP(BuildContext context) async {
    var url = Uri.parse('http://localhost:5000/api/auth/verify-otp');

    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': otpController.text.trim(),
        }),
      );

      setState(() {
        isLoading = false; // Hide loading indicator
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigate to login page
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        var errorMessage =
            jsonDecode(response.body)['msg'] ?? 'Verification failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: Could not verify OTP. $e')),
      );
    }
  }

  Future<void> resendOTP() async {
    var url = Uri.parse('http://localhost:5000/api/auth/resend-otp');

    setState(() {
      isResending = true; // Show loading indicator for resending
    });

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      setState(() {
        isResending = false; // Hide loading indicator
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully!')),
        );
      } else {
        var errorMessage =
            jsonDecode(response.body)['msg'] ?? 'Resending failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      setState(() {
        isResending = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: Could not resend OTP. $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'animations/loading.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Verifying OTP...",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40.0),
                        const Text(
                          'Verify Your Email',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'An OTP has been sent to ${widget.email}. Please enter it below to verify your account.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter OTP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.purple.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => verifyOTP(context),
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                      ),
                      child: const Text(
                        'Verify OTP',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Haven't received OTP? ",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                            isResending
                                ? Lottie.asset(
                                    'animations/loading.json',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : TextButton(
                                    onPressed: resendOTP,
                                    child: const Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
