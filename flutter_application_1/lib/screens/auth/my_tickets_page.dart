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

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('tickets')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (response == null) return [];
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTickets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final tickets = snapshot.data!;
        if (tickets.isEmpty) return const Center(child: Text("No tickets found"));

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (_, index) {
            final ticket = tickets[index];
            final destination = ticket['destination_name'] ?? 'Unknown Destination';
            final ticketCount = ticket['tickets_count'] ?? 0;
            final total = ticket['total'] ?? 0;

            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(destination),
                subtitle: Text("Tickets: $ticketCount | Total: ৳$total"),
                trailing: const Icon(Icons.qr_code),
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
              ),
            );
          },
        );
      },
    );
  }
}
