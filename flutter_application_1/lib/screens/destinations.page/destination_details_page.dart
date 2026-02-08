import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DestinationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> destination;

  const DestinationDetailsPage({super.key, required this.destination});

  @override
  State<DestinationDetailsPage> createState() => _DestinationDetailsPageState();
}

class _DestinationDetailsPageState extends State<DestinationDetailsPage> {
  final SupabaseClient _client = Supabase.instance.client;
  DateTime? _selectedDate; // User-selected travel date
  int _quantity = 1; // Ticket quantity

  @override
  Widget build(BuildContext context) {
    final double price = (widget.destination['price'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destination['name'] ?? 'Destination'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Image
            Image.network(
              widget.destination['image_url'] ?? '',
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 240,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    widget.destination['name'] ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        widget.destination['location'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.destination['description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trip Cost',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '৳ $price',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Travel Date Picker
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'No travel date selected'
                              : 'Travel Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickTravelDate(context),
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ticket Quantity Selector
                  Row(
                    children: [
                      const Text('Quantity:'),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Text('$_quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Total Price
                  Text(
                    'Total Price: ৳ ${price * _quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _bookTicket(context),
                      child: const Text('Book Now', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // Date Picker Function
  // ======================
  Future<void> _pickTravelDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  // ======================
  // Book Ticket Function
  // ======================
  Future<void> _bookTicket(BuildContext context) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে আগে লগইন করুন')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে ট্রাভেল তারিখ নির্বাচন করুন')),
      );
      return;
    }

    final double price = (widget.destination['price'] ?? 0).toDouble();
    final double totalPrice = price * _quantity;

    try {
      await _client.from('tickets').insert({
        'user_id': user.id,
        'destination_id': widget.destination['id'],
        'quantity': _quantity,
        'booked_at': DateTime.now().toIso8601String(),
        'travel_date': _selectedDate!.toIso8601String().split('T')[0],
        'total_price': totalPrice,
        'payment_status': 'pending', // <- changed here
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking সফল হয়েছে 🎉')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking ব্যর্থ হয়েছে: $e')),
        );
      }
    }
  }
}
