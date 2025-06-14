import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:food/canteen_selection/canteen_selection.dart';
import 'package:food/canteen_selection/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'SignUpScreen.dart';
import 'selectrole.dart';
import 'utils/colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _cloudIDController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  bool _rememberMe = false; // Remember Me state

  @override
  void initState() {
    super.initState();
    _loadLoginDetails(); // Load saved login details on initialization
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserTypeScreen()),
                      );
                    },
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logo.webp'), // Ensure the logo is in assets/images
                  ),
                  SizedBox(height: 20),
                  Text(
                    'NED QuickServe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Log In to QuickServe',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                    textAlign: TextAlign.center,
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
                            label: 'ID',
                            hint: 'Enter your  ID',
                            icon: Icons.badge,
                          ),
                          SizedBox(height: 20), _buildTextField(
                            controller: _nameController,
                            label: 'Name',
                            hint: 'Enter your  Name',
                            icon: Icons.person,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock,
                            obscureText: true,
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value!;
                                  });
                                },
                              ),
                              Text(
                                "Remember Me",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: _logIn, // Call the login function when tapped
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.themeColor, AppColors.themeColor],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StaffSignUpScreen("Staff")),
                      );
                    },
                    child: Text(
                      'Don\'t have an account? Sign Up',
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
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        prefixIcon: Icon(icon, color: AppColors.themeColor),
      ),
    );
  }

  Future<void> _logIn() async {
    String cloudID = _cloudIDController.text.trim();
    String password = _passwordController.text.trim();

    if (cloudID.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: cloudID,
        password: password,
      );

      if (userCredential.user != null) {
        if (_rememberMe) {
          await _saveLoginDetails();
        }
        SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
        sharedPreferences.setString('id', _cloudIDController.text);
        sharedPreferences.setString('name', _nameController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? "Something went wrong. Please try again.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _saveLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cloudID', _cloudIDController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('name', _nameController.text);
  }

  Future<void> _loadLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cloudIDController.text = prefs.getString('cloudID') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _nameController.text= prefs.getString('name') ?? '';
    });
  }
}