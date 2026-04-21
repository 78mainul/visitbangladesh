import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';

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
  final TextEditingController referralCtrl = TextEditingController();

  String category = 'Bangladeshi';
  bool showPassword = false;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidMobile(String mobile) {
    return RegExp(r'^01[3-9]\d{8}$').hasMatch(mobile);
  }

  Future<void> _signup() async {
    final name = nameCtrl.text.trim();
    final mobile = mobileCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    final referral = referralCtrl.text.trim();

    if (name.isEmpty || mobile.isEmpty || email.isEmpty || password.isEmpty) {
      _showPopup("সব তথ্য পূরণ করুন");
      return;
    }

    if (!isValidEmail(email)) {
      _showPopup("ইমেইল সঠিক নয়");
      return;
    }

    if (!isValidMobile(mobile)) {
      _showPopup("মোবাইল নাম্বার সঠিক নয়");
      return;
    }

    if (password.length < 6) {
      _showPopup("পাসওয়ার্ড কমপক্ষে 6 অক্ষর হতে হবে");
      return;
    }

    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        setState(() => isLoading = false);
        _showPopup("Signup failed!");
        return;
      }

      await supabase.from('users').insert({
        'id': user.id,
        'name': name,
        'mobile': mobile,
        'email': email,
        'category': category,
        'referral_code': referral,
        'created_at': DateTime.now().toIso8601String(),
      });

      _showPopup("অ্যাকাউন্ট তৈরি হয়েছে!");

      nameCtrl.clear();
      mobileCtrl.clear();
      emailCtrl.clear();
      passCtrl.clear();
      referralCtrl.clear();

      setState(() => category = 'Bangladeshi');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      _showPopup("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showPopup(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Message"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    referralCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/cover.png',
              fit: BoxFit.cover,
            ),
          ),

          Container(color: Colors.black.withOpacity(0.65)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _buildField(nameCtrl, "Full Name"),
                  _buildField(mobileCtrl, "Mobile Number",
                      type: TextInputType.phone),
                  _buildField(emailCtrl, "Email",
                      type: TextInputType.emailAddress),

                  // PASSWORD
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: passCtrl,
                      obscureText: !showPassword,
                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.25),

                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.white70),

                        floatingLabelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () =>
                              setState(() => showPassword = !showPassword),
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),

                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),

                  // 🔥 DROPDOWN FIXED FULL WHITE STYLE
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: category,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),

                      iconEnabledColor: Colors.white,

                      dropdownColor: Colors.black,

                      items: const [
                        DropdownMenuItem(
                          value: "Bangladeshi",
                          child: Text(
                            "🇧🇩 Bangladeshi",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Foreigner",
                          child: Text(
                            "🌍 Foreigner",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],

                      onChanged: (val) {
                        setState(() => category = val ?? "Bangladeshi");
                      },

                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.25),

                        labelText: "Select nationality",
                        labelStyle: const TextStyle(color: Colors.white70),

                        floatingLabelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),

                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),

                  _buildField(referralCtrl, "Referral Code (optional)"),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text("Sign Up"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text("Login"),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 FINAL FIELD
  Widget _buildField(TextEditingController ctrl, String label,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: type,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),

        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black.withOpacity(0.25),

          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),

          floatingLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

          hintText: label,
          hintStyle: const TextStyle(color: Colors.white54),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}