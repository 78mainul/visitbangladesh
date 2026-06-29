import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_screen.dart';
import '../auth/my_tickets_page.dart';
import '../DestinationListPage/destination_details_page.dart';
import '../profile/profile_page.dart';
import '../reviews/reviews_page.dart';

class ModernDashboard extends StatefulWidget {
  const ModernDashboard({super.key});

  @override
  State<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends State<ModernDashboard> {

  int selectedIndex = 0;

  final SupabaseClient client = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> futureDestinations;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  void _loadDestinations() {
    futureDestinations = client
        .from('destinations')
        .select()
        .then((value) => List<Map<String, dynamic>>.from(value));
  }

  Future<void> _refresh() async {
    setState(() {
      _loadDestinations();
    });
  }

  Future<void> _logout() async {
    await client.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: DestinationSearch(client),
    );
  }

  Widget _buildBody() {
    switch (selectedIndex) {
      case 0:
        return _buildHome();

      case 1:
        return const MyTicketsPage();

      case 2:
        return const ReviewsPage();

      case 3:
        return const ProfilePage();

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          "Tourism App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
        ],
      ),

      drawer: _buildDrawer(),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Reviews"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
            ),
            child: Text(
              "Tourism Dashboard",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              setState(() => selectedIndex = 0);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: const Text("My Tickets"),
            onTap: () {
              setState(() => selectedIndex = 1);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // ===============================
  // HOME (FIXED SCOPE + CLEAN)
  // ===============================
  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureDestinations,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingGrid();
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("No Destinations Found"));
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {

                final d = data[index];

                return _DestinationCard(
                  name: d['name'] ?? '',
                  location: d['location'] ?? '',
                  image: d['image_url'] ?? '',
                  onTap: () {
                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DestinationDetailsPage(destination: d),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ===============================
// CARD UI (IMPROVED IMAGE SAFETY)
// ===============================
class _DestinationCard extends StatelessWidget {
  final String name;
  final String location;
  final String image;
  final VoidCallback onTap;

  const _DestinationCard({
    required this.name,
    required this.location,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================
// LOADING UI
// ===============================
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ===============================
// SEARCH (UNCHANGED BUT SAFE)
// ===============================
class DestinationSearch extends SearchDelegate {
  final SupabaseClient client;

  DestinationSearch(this.client);

  Future<List<Map<String, dynamic>>> _search(String q) async {
    final res = await client
        .from('destinations')
        .select()
        .or('name.ilike.%$q%,location.ilike.%$q%');

    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: _search(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return const Center(child: Text("No Results Found"));
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, i) {
            final d = data[i];

            return ListTile(
              leading: const Icon(Icons.place),
              title: Text(d['name'] ?? ''),
              subtitle: Text(d['location'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DestinationDetailsPage(destination: d),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );
}