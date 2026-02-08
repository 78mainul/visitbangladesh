import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart'; // Login screen path ঠিক করুন

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  String category = 'Bangladeshi';
  bool showPassword = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/cover.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome to Visit Bangladesh',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please Sign Up here',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 32),

                    // Name
                    _buildTextField(nameCtrl, 'Full Name'),
                    const SizedBox(height: 16),
                    // Mobile
                    _buildTextField(mobileCtrl, 'Mobile Number', keyboard: TextInputType.phone),
                    const SizedBox(height: 16),
                    // Email
                    _buildTextField(emailCtrl, 'Email', keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    // Password
                    TextField(
                      controller: passCtrl,
                      obscureText: !showPassword,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Password (min 6 chars)',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Category',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Bangladeshi', child: Text('Bangladeshi')),
                        DropdownMenuItem(value: 'Foreigner', child: Text('Foreigner')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => category = value);
                      },
                    ),
                    const SizedBox(height: 32),
                    // SignUp Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Already have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?', style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Text('Login', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Helper TextField
  // =========================
  Widget _buildTextField(TextEditingController ctrl, String label, {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.auto, // label goes up on focus
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // =========================
  // SignUp Function
  // =========================
  Future<void> _signup() async {
    final name = nameCtrl.text.trim();
    final mobile = mobileCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (name.isEmpty || mobile.isEmpty || email.isEmpty || password.isEmpty) {
      _showPopup('সকল তথ্য দিতে হবে');
      return;
    }

    if (password.length < 6) {
      _showPopup('Password কমপক্ষে 6 অক্ষরের হতে হবে');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _showPopup('Signup failed! Email already registered?');
        return;
      }

      // Insert into DB
      await Supabase.instance.client.from('users').insert({
        'name': name,
        'mobile': mobile,
        'email': email,
        'category': category,
      });

      _showPopup('অ্যাকাউন্ট তৈরি হয়েছে! লগইন করুন।');

      // Clear fields
      nameCtrl.clear();
      mobileCtrl.clear();
      emailCtrl.clear();
      passCtrl.clear();
      setState(() => category = 'Bangladeshi');
    } catch (e) {
      _showPopup('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // =========================
  // Popup
  // =========================
  void _showPopup(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Message'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }
}
