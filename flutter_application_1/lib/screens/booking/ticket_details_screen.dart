import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String destination;
  final int total;
  final int tickets;

  const TicketDetailsScreen({
    super.key,
    required this.destination,
    required this.total,
    required this.tickets,
  });

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> _saveTicket() async {
    Uint8List? image = await screenshotController.capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: 3.0,
    );
    if (image == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(image);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket saved to app directory!')),
    );
  }

  Future<void> _shareTicket() async {
    Uint8List? image = await screenshotController.capture(
      delay: const Duration(milliseconds: 10),
      pixelRatio: 3.0,
    );
    if (image == null) return;

    final tempFile = XFile.fromData(
      image,
      mimeType: 'image/png',
      name: 'my_ticket.png',
    );

    await Share.shareXFiles(
      [tempFile],
      text: 'My Ticket for ${widget.destination}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData =
        "Destination: ${widget.destination}\nTickets: ${widget.tickets}\nTotal: ৳${widget.total}";

    return Scaffold(
      appBar: AppBar(title: const Text("Your Ticket")),
      body: Center(
        child: Screenshot(
          controller: screenshotController,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.destination,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Tickets: ${widget.tickets}"),
                  Text("Total: ৳${widget.total}"),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: qrData,
                    size: 200,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                        onPressed: _saveTicket,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        onPressed: _shareTicket,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
