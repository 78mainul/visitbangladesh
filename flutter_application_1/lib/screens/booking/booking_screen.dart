import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/destination.dart';
import 'ticket_details_screen.dart';

class BookingScreen extends StatefulWidget {
  final Destination destination;

  const BookingScreen({super.key, required this.destination});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int tickets = 1;
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    // Null safe total calculation
    int total = tickets * (widget.destination.price ?? 0);

    return Scaffold(
      appBar: AppBar(title: Text(widget.destination.name ?? 'Unknown Destination')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Price per ticket: ৳${widget.destination.price ?? 0}"),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Tickets: "),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() => tickets = tickets > 1 ? tickets - 1 : 1),
                ),
                Text("$tickets"),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => tickets++),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Total: ৳$total", style: const TextStyle(fontSize: 20)),
            const Spacer(),
            ElevatedButton(
              child: const Text("Confirm Booking"),
              onPressed: () async {
                final user = _client.auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("You must be logged in to book tickets!")),
                  );
                  return;
                }

                // Prepare ticket data (null-safe)
                final ticketData = {
                  'user_id': user.id,
                  'destination_id': widget.destination.id ?? 0,
                  'destination_name': widget.destination.name ?? 'Unknown Destination',
                  'total': total,
                  'tickets_count': tickets,
                  'created_at': DateTime.now().toIso8601String(),
                };

                try {
                  // Insert into Supabase safely
                  await _client.from('tickets').insert(ticketData).select();

                  // Navigate to TicketDetailsScreen
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailsScreen(
                        destination: widget.destination.name ?? 'Unknown Destination',
                        total: total,
                        tickets: tickets,
                      ),
                    ),
                  );
                } catch (e) {
                  // Error handling
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Booking failed: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
