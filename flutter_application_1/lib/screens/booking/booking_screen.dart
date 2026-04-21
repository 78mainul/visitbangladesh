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
  bool _loading = false;
  DateTime? travelDate;

  final SupabaseClient _client = Supabase.instance.client;

  int get price => widget.destination.price ?? 0;
  int get total => tickets * price;

  // 📅 Date Picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        travelDate = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_loading) return;

    // ❗ validation
    if (travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select travel date")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be logged in to book tickets!")),
        );
        return;
      }

      // ✅ FIXED DATA (matches your DB exactly)
      final ticketData = {
        'user_id': user.id,
        'destination_id': widget.destination.id,
        'destination_name': widget.destination.name,
        'tickets_count': tickets.toString(), // DB = text তাই string
        'total_price': total,                // ✅ correct column name
        'travel_date': travelDate!.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client.from('tickets').insert(ticketData);

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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed ❌: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _increase() => setState(() => tickets++);
  void _decrease() {
    if (tickets > 1) setState(() => tickets--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: Text(widget.destination.name ?? 'Booking'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PriceCard(price: price),

            const SizedBox(height: 20),

            // 📅 DATE PICKER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Travel Date",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      travelDate == null
                          ? "Select Date"
                          : "${travelDate!.toLocal()}".split(' ')[0],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            _CounterCard(
              tickets: tickets,
              onAdd: _increase,
              onRemove: _decrease,
            ),

            const Spacer(),

            _TotalCard(total: total),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- PRICE CARD ---------------- */

class _PriceCard extends StatelessWidget {
  final int price;

  const _PriceCard({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "Price per ticket: ৳$price",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/* ---------------- COUNTER CARD ---------------- */

class _CounterCard extends StatelessWidget {
  final int tickets;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CounterCard({
    required this.tickets,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Tickets"),
          Row(
            children: [
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle),
              ),
              Text("$tickets"),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/* ---------------- TOTAL CARD ---------------- */

class _TotalCard extends StatelessWidget {
  final int total;

  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "Total: ৳$total",
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}