import 'dart:async'; // For Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'canteen_selection/canteen_selection.dart';
import 'selectrole.dart';
import 'loginScreen.dart'; // Ensure LoginScreen is implemented
import 'utils/colors.dart'; // Ensure your themeColor is defined as maroon or similar.

class StaffSignUpScreen extends StatefulWidget {
  final String type; // Role (Student, Teacher, Staff)
  StaffSignUpScreen(this.type);

  @override
  State<StaffSignUpScreen> createState() => _StaffSignUpScreenState();
}

class _StaffSignUpScreenState extends State<StaffSignUpScreen> {
  final TextEditingController _cloudIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isIDValid = false; // Track if Cloud ID exists in Firestore

  // Function to validate Cloud ID based on role
  bool isValidCloudIDFormat(String cloudID) {
    if (widget.type == 'Student' && !cloudID.endsWith("@cloud.neduet.edu.pk")) {
      return false;
    } else if (widget.type == 'Teacher' && !cloudID.endsWith("@neduet.edu.pk")) {
      return false;
    } else if (widget.type == 'Staff' && !cloudID.endsWith("@gmail.com")) {
      return false;
    }
    return true;
  }

  // Function to check if Cloud ID exists in Firestore
  Future<void> _checkCloudID() async {
    String cloudID = _cloudIDController.text.trim();

    if (cloudID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your Cloud ID.")),
      );
      return;
    }

    // Validate Cloud ID format based on role
    if (!isValidCloudIDFormat(cloudID)) {
      String errorMessage = widget.type == 'Student'
          ? "Invalid Student ID. Use '@cloud.neduet.edu.pk'."
          : widget.type == 'Teacher'
          ? "Invalid Teacher ID. Use '@neduet.edu.pk'."
          : "Invalid Staff ID. Use '@gmail.com'.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    // Query Firestore for matching Cloud ID
    var usersCollection = FirebaseFirestore.instance.collection('Users');
    var querySnapshot = await usersCollection.where('cloudId', isEqualTo: cloudID).get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _isIDValid = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cloud ID verified. You can create a password.")),
      );
    } else {
      setState(() {
        _isIDValid = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cloud ID not found. Contact admin.")),
      );
    }
  }

  // Sign Up Function
  Future<void> _signUp() async {
    try {
      String cloudID = _cloudIDController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();

      // Validate fields
      if (!_isIDValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please verify your Cloud ID first.")),
        );
        return;
      }

      if (password.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all password fields.")),
        );
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match.")),
        );
        return;
      }

      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: cloudID,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification email sent. Please verify your email.")),
      );

      // Start polling for email verification
      _startVerificationCheck();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  // Polling to check email verification status
  void _startVerificationCheck() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _auth.currentUser?.reload(); // Reload current user data
      if (_auth.currentUser?.emailVerified ?? false) {
        timer.cancel(); // Stop polling
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.themeColor, AppColors.themeColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserTypeScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logo.webp'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sign Up as ${widget.type}',
                    style: TextStyle(
                      color: AppColors.white ,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _cloudIDController,
                            label: 'Cloud ID',
                            hint: 'Enter your Cloud ID',
                            icon: Icons.email,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _checkCloudID,
                            child: Text("Verify Cloud ID",style: TextStyle(color: AppColors.whiteColor)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.themeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                            ),
                          ),
                          if (_isIDValid) ...[
                            SizedBox(height: 15),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Create Password',
                              hint: 'Enter your password',
                              icon: Icons.lock,
                              obscureText: true,
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: 'Re-enter your password',
                              icon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _signUp,
                              child: Text("Sign Up",style: TextStyle(color: AppColors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.themeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Already have an account? Log In',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        prefixIcon: Icon(icon, color: AppColors.themeColor),
      ),
    );
  }
}