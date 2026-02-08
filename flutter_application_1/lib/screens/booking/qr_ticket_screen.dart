import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRTicketScreen extends StatelessWidget {
  final String destination;
  final int total;

  const QRTicketScreen({
    super.key,
    required this.destination,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = "Destination: $destination | Total: $total";

    return Scaffold(
      appBar: AppBar(title: const Text("Your Ticket")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              size: 250,
            ),
            const SizedBox(height: 20),
            Text("Show this QR at entrance"),
          ],
        ),
      ),
    );
  }
}
