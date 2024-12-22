import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/src/features/First_screen/seller/main_page.dart';
import 'package:myapp/src/features/First_screen/seller/seller_home_page.dart';

import 'package:myapp/src/features/user/user_screen.dart';
import 'package:myapp/src/settings/settings_controller.dart';
import 'package:myapp/src/settings/settings_service.dart';
import 'package:myapp/utils/button.dart';

import 'dart:convert';
import 'package:myapp/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  static const routeName = 'FirstScreen';

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController(SettingsService());
    _settingsController.loadSettings().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _settingsController.themeMode == ThemeMode.dark
              ? ThemeData.dark()
              : ThemeData.light(),
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: backgroundColor ?? Colors.blue,
              title: const Text(
                'SURDS',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(_settingsController.themeMode == ThemeMode.dark
                      ? Icons.wb_sunny
                      : Icons.brightness_2),
                  onPressed: () {
                    _settingsController.updateThemeMode(
                      _settingsController.themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark,
                    );
                  },
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/Surds.png",
                    height: 150,
                    width: 150,
                    colorBlendMode: BlendMode.modulate,
                  ),
                  const SizedBox(height: 20),
                  SimpleRoundButton(
                    backgroundColor: Colors.redAccent,
                    buttonText: const Text(
                      "LOGIN",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(_settingsController)),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SimpleRoundButton(
                    backgroundColor: Colors.redAccent,
                    buttonText: const Text(
                      "SIGN UP",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignupScreen(_settingsController)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  final SettingsController settingsController;
  const LoginScreen(this.settingsController, {super.key});
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    void showSellerOptionDialog(
        BuildContext context, Map<String, dynamic> user) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Seller Account Detected'),
            content: const Text(
                'Your account is registered as a seller. Where would you like to go?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  // Navigate to user home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserHomeScreen(
                          settingsController: settingsController),
                    ),
                  );
                },
                child: const Text('User Home'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  // Navigate to seller home page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(
                        sellerId: user['seller'],
                        settingsController: settingsController,
                      ),
                    ),
                  );
                },
                child: const Text('Seller Page'),
              ),
            ],
          );
        },
      );
    }

    Future<void> login(BuildContext context) async {
      final String email = emailController.text.trim();
      final String password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('$uri/api/signin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String? token = responseData['token'] as String?;
        Map<String, dynamic> user =
            responseData['user'] as Map<String, dynamic>;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token ?? '');

        String? userType = user['type'] as String?;

        if (userType == 'seller') {
          // Show dialog to choose between seller page or user page
          showSellerOptionDialog(context, user);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserHomeScreen(settingsController: settingsController),
            ),
          );
        }
      } else {
        String errorMessage = 'Failed to login';
        try {
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          errorMessage =
              errorResponse['msg'] ?? errorResponse['error'] ?? errorMessage;
        } catch (e) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          // Use SingleChildScrollView to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Image.asset('assets/images/banana.jpg'),
                    const SizedBox(width: 10),
                    Image.asset('assets/images/diaper.jpg'),
                    const SizedBox(width: 10),
                    Image.asset('assets/images/snack.jpg'),
                    const SizedBox(width: 10),
                    Image.asset('assets/images/cereal.jpg'),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fooder',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "India's fastest app",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  login(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 20),
              const Text('OR', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Image.asset('assets/images/google_logo.jpg', height: 24),
                label: const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.grey),
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

class SignupScreen extends StatefulWidget {
  final SettingsController settingsController;
  const SignupScreen(this.settingsController, {super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Seller-specific controllers
  final TextEditingController storeNameController = TextEditingController();

  // Account type toggle
  bool _isSeller = false; // Default is user

  @override
  void dispose() {
    // Dispose controllers when not needed
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    storeNameController.dispose();
    super.dispose();
  }

  Future<void> signup(BuildContext context) async {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String type = _isSeller ? 'seller' : 'user';

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'password': password,
      'type': type,
    };

    if (_isSeller) {
      final String storeName = storeNameController.text.trim();
      if (storeName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a store name')),
        );
        return;
      }
      requestBody['storeName'] = storeName;
      // Collect other necessary seller-specific fields if required
    }

    final response = await http.post(
      Uri.parse('$uri/api/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      String token = responseData['token'];
      Map<String, dynamic> user = responseData['user'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      String userType = user['type'];

      if (userType == 'seller') {
        // Access the seller ID
        Map<String, dynamic> sellerId = user['seller'];
        print(sellerId);
        // Show dialog to choose between seller page or user page
        // _showSellerOptionDialog(context, sellerId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(
                sellerId: sellerId,
                settingsController: widget.settingsController),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserHomeScreen(settingsController: widget.settingsController),
          ),
        );
      }
    } else {
      String errorMessage = 'Failed to sign up';
      try {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        errorMessage =
            errorResponse['msg'] ?? errorResponse['error'] ?? errorMessage;
      } catch (e) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _showSellerOptionDialog(
      BuildContext context, Map<String, dynamic> sellerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seller Account Created'),
          content: const Text(
              'Your seller account has been created. Where would you like to go?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Navigate to user home screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserHomeScreen(
                        settingsController: widget.settingsController),
                  ),
                );
              },
              child: const Text('User Home'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Navigate to seller home page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(
                      sellerId: sellerId,
                      settingsController: widget.settingsController,
                    ),
                  ),
                );
              },
              child: const Text('Seller Page'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          // Use SingleChildScrollView to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              // Toggle between user and seller
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sign up as Seller'),
                  Switch(
                    value: _isSeller,
                    onChanged: (value) {
                      setState(() {
                        _isSeller = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              // Seller-specific fields
              if (_isSeller) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: storeNameController,
                  decoration: InputDecoration(
                    hintText: 'Store Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Add more seller-specific fields if needed
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  signup(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 20),
              const Text('OR', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Image.asset('assets/images/google_logo.jpg', height: 24),
                label: const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.grey),
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
