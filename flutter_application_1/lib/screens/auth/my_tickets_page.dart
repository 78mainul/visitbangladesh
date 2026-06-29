import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✨ নতুন dependency
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../booking/ticket_details_screen.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  final SupabaseClient _client = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> _futureTickets;

  @override
  void initState() {
    super.initState();
    _futureTickets = _fetchTickets();
  }

  // 🎯 Supabase থেকে user ticket load করা
  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    try {
      final user = _client.auth.currentUser;

      // যদি user না থাকে তাহলে empty list return
      if (user == null) return [];

      final response = await _client
          .from('tickets')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Fetch error: $e");
      return [];
    }
  }

  // 🔄 Pull to refresh
  Future<void> _refresh() async {
    setState(() {
      _futureTickets = _fetchTickets();
    });
  }

  // 🧠 নিরাপদভাবে number convert করা (crash avoid)
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // 🧠 safe string convert
  String _parseString(dynamic value) {
    if (value == null) return "Unknown";
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),

      // 🔄 Refresh indicator
      body: RefreshIndicator(
        onRefresh: _refresh,

        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureTickets,
          builder: (context, snapshot) {

            // ⏳ Loading UI (shimmer effect)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerList();
            }

            final tickets = snapshot.data ?? [];

            // ❌ Empty state UI
            if (tickets.isEmpty) {
              return const Center(
                child: Text(
                  "No tickets found 🎫",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // 📌 Ticket list UI
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),

              itemBuilder: (_, index) {
                final ticket = tickets[index];

                final destination =
                    _parseString(ticket['destination_name']);

                final ticketCount =
                    _parseInt(ticket['tickets_count']);

                final total =
                    _parseInt(ticket['total_price']);

                return _TicketCard(
                  destination: destination,
                  tickets: ticketCount,
                  total: total,
                  index: index,
                  onTap: () {
                    // 🎯 ticket details page open
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailsScreen(
                          ticketId: ticket['id'] // ✅ শুধু এটা
                        ),
                      ),
                    ).then((_) => _refresh());
                  },
                )
                    // ✨ animation effect
                    .animate()
                    .fade(duration: 300.ms)
                    .slideX(begin: 0.2);
              },
            );
          },
        ),
      ),
    );
  }

  // 🌫️ Shimmer loading UI (pro feel)
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ---------------- UI CARD ---------------- */

class _TicketCard extends StatelessWidget {
  final String destination;
  final int tickets;
  final int total;
  final VoidCallback onTap;
  final int index;

  const _TicketCard({
    required this.destination,
    required this.tickets,
    required this.total,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),

          // 🌟 soft white card (PRO LOOK)
          color: Colors.white,

          // 🌑 subtle shadow (important for premium feel)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Row(
            children: [

              // ✈️ ICON BADGE (modern circle design)
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.teal.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              // 📍 TEXT SECTION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // destination name
                    Text(
                      destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // small info row
                    Row(
                      children: [

                        // tickets chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Tickets: $tickets",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // price chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "৳$total",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 👉 arrow indicator (pro touch)
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}