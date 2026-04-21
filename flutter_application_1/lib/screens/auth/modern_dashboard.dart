import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_screen.dart';
import '../auth/my_tickets_page.dart';
import '../DestinationListPage/destination_details_page.dart';
import '../DestinationListPage/destination_list_page.dart';

class ModernDashboard extends StatefulWidget {
  const ModernDashboard({super.key});

  @override
  State<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends State<ModernDashboard> {
  int selectedIndex = 0;

  final SupabaseClient _client = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> _futureDestinations;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureDestinations = _client
        .from('destinations')
        .select()
        .then((value) => List<Map<String, dynamic>>.from(value));
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }

  void _logout() async {
    await _client.auth.signOut();

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
      delegate: DestinationSearch(_client),
    );
  }

  Widget _body() {
    switch (selectedIndex) {
      case 0:
        return _homeBody();
      case 1:
        return const MyTicketsPage();
      case 2:
        return const Center(child: Text("Reviews ⭐"));
      case 3:
        return const Center(child: Text("Profile 👤"));
      default:
        return const SizedBox();
    }
  }

  Widget _homeBody() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureDestinations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingGrid();
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong 😢"),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("No destinations found"));
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: data.length,
              itemBuilder: (context, i) {
                final d = data[i];

                return _DestinationCard(
                  name: d['name'] ?? '',
                  location: d['location'] ?? '',
                  image: d['image_url'] ??
                      'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DestinationDetailsPage(destination: d),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text("Tourism App"),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          )
        ],
      ),

      drawer: _buildDrawer(),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _body(),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        selectedItemColor: Colors.green,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number), label: "Tickets"),
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
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
              ),
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
}

/* ---------------- CARD UI ---------------- */

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black87,
                Colors.transparent,
              ],
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                location,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- LOADING UI ---------------- */

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
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

/* ---------------- SEARCH ---------------- */

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

        if (snapshot.hasError) {
          return const Center(child: Text("Search failed"));
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return const Center(child: Text("No results found"));
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
                    builder: (_) =>
                        DestinationDetailsPage(destination: d),
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
        onPressed: () => close(context, ''),
      );
}