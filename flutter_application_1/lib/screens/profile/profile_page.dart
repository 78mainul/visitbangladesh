import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDemo();
  }

  Future<void> loadDemo() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      userData = {
        "name": "Mainul Islam",
        "email": "amar@gmail.com",
        "mobile": "01937309224",
        "category": "Main User",
        "referral_code": "DEMO123",
        "created_at": "2026-06-10",
      };

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            Text(
              userData?['name'] ?? "No Name",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            _tile(Icons.email, "Email", userData?['email'] ?? ""),
            _tile(Icons.phone, "Mobile", userData?['mobile'] ?? ""),
            _tile(Icons.flag, "Category", userData?['category'] ?? ""),
            _tile(Icons.card_giftcard, "Referral Code",
                userData?['referral_code'] ?? ""),
            _tile(Icons.calendar_month, "Created",
                userData?['created_at'] ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}