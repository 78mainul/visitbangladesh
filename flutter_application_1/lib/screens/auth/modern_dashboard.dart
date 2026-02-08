import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../destinations.page/destination_details_page.dart';
import '../auth/login_screen.dart';
import '../auth/my_tickets_page.dart'; // ✅ My Tickets Page import

/// =======================
/// USER DASHBOARD PAGE
/// =======================
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int selectedIndex = 0; // BottomNavigationBar এর ইনডেক্স ট্র্যাক করার জন্য

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Bangladesh'), // অ্যাপের শিরোনাম
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          // ==========================
          // সার্চ বাটন
          // ==========================
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DestinationSearch(), // সার্চ ডেলিগেট কল
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'Hello, Tourist!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            // ==========================
            // Drawer Menu Items
            // ==========================
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                setState(() => selectedIndex = 0);
                Navigator.pop(context); // Drawer বন্ধ
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('My Tickets'),
              onTap: () {
                setState(() => selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Reviews'),
              onTap: () {
                setState(() => selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                setState(() => selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // ==========================
                // Logout Logic
                // ==========================
                await Supabase.instance.client.auth.signOut(); // Supabase থেকে logout
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(), // LoginScreen-এ ফিরে যাবে
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _buildPage(), // BottomNavigationBar অনুযায়ী page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => selectedIndex = index); // BottomNavigationBar tap হ্যান্ডেল
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: 'Reviews'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  /// ==========================
  /// BottomNavigationBar অনুযায়ী page রেন্ডার
  /// ==========================
  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return const DestinationListPage(); // Home page
      case 1:
        return MyTicketsPage(); // My Tickets Page
      case 2:
        return const Center(child: Text('Reviews Page', style: TextStyle(fontSize: 22)));
      case 3:
        return const Center(child: Text('Profile Page', style: TextStyle(fontSize: 22)));
      default:
        return const SizedBox();
    }
  }
}

/// =======================
/// DESTINATION LIST PAGE
/// =======================
class DestinationListPage extends StatefulWidget {
  const DestinationListPage({super.key});

  @override
  State<DestinationListPage> createState() => _DestinationListPageState();
}

class _DestinationListPageState extends State<DestinationListPage> {
  final SupabaseClient _client = Supabase.instance.client; // Supabase Client

  // ==========================
  // ডাটাবেস থেকে সব ডেস্টিনেশন ফেচ করা
  // ==========================
  Future<List<Map<String, dynamic>>> _fetchDestinations() async {
    final response = await _client.from('destinations').select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchDestinations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // লোডিং ইন্ডিকেটর
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Error দেখাবে
        }
        final destinations = snapshot.data;
        if (destinations == null || destinations.isEmpty) {
          return const Center(child: Text('কোনো Destination পাওয়া যায়নি।'));
        }

        // ==========================
        // GridView এ destination দেখানো
        // ==========================
        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            itemCount: destinations.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final dest = destinations[index];
              return GestureDetector(
                onTap: () {
                  // Destination এর বিস্তারিত পেজে নেভিগেট
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DestinationDetailsPage(destination: dest),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            dest['image_url'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Center(child: Icon(Icons.broken_image, size: 50)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          dest['name'] ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// =======================
/// SEARCH DELEGATE
/// =======================
class DestinationSearch extends SearchDelegate<String> {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')]; // সার্চ ক্লিয়ার
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, '')); // ব্যাক বাটন
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchDestinations(query), // সার্চ ফাংশন কল
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final results = snapshot.data!;
        if (results.isEmpty) return const Center(child: Text('কোনো Destination পাওয়া যায়নি।'));
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, index) {
            final dest = results[index];
            return ListTile(
              title: Text(dest['name'] ?? ''),
              subtitle: Text(dest['location'] ?? ''),
              onTap: () {
                close(context, dest['name'] ?? '');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DestinationDetailsPage(destination: dest)),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchDestinations(query), // টাইপ করার সাথে সাথে সাজেশন
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final suggestions = snapshot.data!;
        if (suggestions.isEmpty) return const Center(child: Text('কোনো Destination পাওয়া যায়নি।'));
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (_, index) {
            final dest = suggestions[index];
            return ListTile(
              title: Text(dest['name'] ?? ''),
              subtitle: Text(dest['location'] ?? ''),
              onTap: () {
                query = dest['name'] ?? '';
                showResults(context); // নির্বাচিত সাজেশন দেখাবে
              },
            );
          },
        );
      },
    );
  }

  /// ==========================
  /// সার্চ ফাংশন (name, location, description)
  /// ==========================
  Future<List<Map<String, dynamic>>> _searchDestinations(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final response = await _client
        .from('destinations')
        .select()
        .or(
          'name.ilike.%${query.trim()}%,' 
          'location.ilike.%${query.trim()}%,' 
          'description.ilike.%${query.trim()}%',
        )
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }
}
