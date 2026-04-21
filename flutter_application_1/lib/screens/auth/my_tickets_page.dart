import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('tickets')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureTickets = _fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text("My Tickets"),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureTickets,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _TicketLoading();
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text("Something went wrong 😢"),
              );
            }

            final tickets = snapshot.data ?? [];

            if (tickets.isEmpty) {
              return const Center(
                child: Text(
                  "No tickets found 🎫",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final ticket = tickets[index];

                final destination =
                    ticket['destination_name'] ?? 'Unknown Destination';

                final ticketCount = ticket['tickets_count'] ?? 0;
                final total = ticket['total'] ?? 0;

                return _TicketCard(
                  destination: destination,
                  tickets: ticketCount,
                  total: total,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailsScreen(
                          destination: destination,
                          tickets: ticketCount,
                          total: total,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/* ---------------- TICKET CARD ---------------- */

class _TicketCard extends StatelessWidget {
  final String destination;
  final int tickets;
  final num total;
  final VoidCallback onTap;

  const _TicketCard({
    required this.destination,
    required this.tickets,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.flight_takeoff, color: Colors.green),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tickets: $tickets",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  "৳$total",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/* ---------------- LOADING UI ---------------- */

class _TicketLoading extends StatelessWidget {
  const _TicketLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}