import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/modern_dashboard.dart'; // ইউজার ড্যাশবোর্ডের স্ক্রিন ইমপোর্ট

// ==========================
// LoginScreen StatefulWidget
// ==========================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController: ইমেইল ও পাসওয়ার্ড ফিল্ডের জন্য
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool isLoading = false; // লগইন চলাকালীন লোডিং দেখানোর জন্য
  bool showPassword = false; // পাসওয়ার্ড দেখানোর/লুকানোর জন্য

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // স্ক্রিন সাইজ

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==========================
          // ব্যাকগ্রাউন্ড ইমেজ
          // ==========================
          Image.asset(
            'assets/images/cover.png',
            fit: BoxFit.cover,
          ),
          // ==========================
          // ডার্ক overlay
          // ==========================
          Container(color: Colors.black.withOpacity(0.5)),
          // ==========================
          // Login Form
          // ==========================
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.08),
                // ==========================
                // Back Button
                // ==========================
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context), // পূর্ববর্তী পেজে ফিরে যাবে
                  ),
                ),
                const SizedBox(height: 20),
                // ==========================
                // App Title
                // ==========================
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please login to your account',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                // ==========================
                // Card Form (ইমেইল ও পাসওয়ার্ড)
                // ==========================
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // ==========================
                        // Email Field
                        // ==========================
                        TextField(
                          controller: emailCtrl, // TextController
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ==========================
                        // Password Field
                        // ==========================
                        TextField(
                          controller: passCtrl,
                          obscureText: !showPassword, // show/hide password
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword; // toggle password visibility
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ==========================
                        // Forgot Password Button
                        // ==========================
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: পাসওয়ার্ড রিসেট লজিক
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ==========================
                        // Login Button
                        // ==========================
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login, // লগইন ফাংশন কল
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  ) // লোডিং
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // LOGIN FUNCTION
  // ==========================
  Future<void> _login() async {
    final email = emailCtrl.text.trim(); // ইমেইল ফিল্ড থেকে মান
    final password = passCtrl.text.trim(); // পাসওয়ার্ড ফিল্ড থেকে মান

    // ==========================
    // Validation (ভ্যালিডেশন)
    // ==========================
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password required')), // ফাঁকা হলে বার্তা দেখাবে
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভুল ইমেইল ঠিকানা')), // ইমেইল ফরম্যাট ভুল হলে
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password কমপক্ষে 6 অক্ষরের হতে হবে')), // পাসওয়ার্ড সংক্ষিপ্ত হলে
      );
      return;
    }

    setState(() => isLoading = true); // লগইন শুরু হলে লোডিং দেখাবে

    try {
      // ==========================
      // Supabase লগইন
      // ==========================
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if ((response.user != null || response.session != null) && mounted) {
        // ==========================
        // লগইন সফল হলে
        // ==========================
        emailCtrl.clear(); // ফিল্ড ক্লিয়ার
        passCtrl.clear(); 

        // Dashboard-এ নেভিগেট
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserDashboard()),
        );
      } else {
        // ==========================
        // লগইন ব্যর্থ হলে
        // ==========================
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed! Check credentials')),
        );
      }
    } catch (e) {
      // ==========================
      // Error হ্যান্ডলিং
      // ==========================
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false); // লোডিং বন্ধ
    }
  }
}
