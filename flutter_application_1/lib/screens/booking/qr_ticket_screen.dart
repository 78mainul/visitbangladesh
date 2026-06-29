import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String ticketId;
  final String destination;
  final int tickets;
  final int total;

  const TicketDetailsScreen({
    super.key,
    required this.ticketId,
    required this.destination,
    required this.tickets,
    required this.total,
  });

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final ScreenshotController controller = ScreenshotController();
  bool loading = false;

  String get qrData =>
      "TICKET_ID: ${widget.ticketId}\nDEST: ${widget.destination}\nTICKETS: ${widget.tickets}\nTOTAL: ৳${widget.total}";

  Future<Uint8List?> capture() async {
    return await controller.capture(pixelRatio: 3.0);
  }

  Future<void> saveTicket() async {
    setState(() => loading = true);

    try {
      final image = await capture();
      if (image == null) return;

      final dir = await getApplicationDocumentsDirectory();

      final file = File(
        "${dir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      await file.writeAsBytes(image);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved ✅")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> shareTicket() async {
    setState(() => loading = true);

    try {
      final image = await capture();
      if (image == null) return;

      final xfile = XFile.fromData(image, name: "ticket.png");

      await Share.shareXFiles([xfile], text: "My Ticket 🎫");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ticket"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Screenshot(
          controller: controller,
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.blueGrey],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(Icons.airplane_ticket, color: Colors.white, size: 40),

                const SizedBox(height: 10),

                Text(
                  widget.destination,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),

                const SizedBox(height: 10),

                Text("Tickets: ${widget.tickets}", style: const TextStyle(color: Colors.white)),
                Text("Total: ৳${widget.total}", style: const TextStyle(color: Colors.white)),

                const SizedBox(height: 15),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: QrImageView(
                    data: qrData,
                    size: 180,
                  ),
                ),

                const SizedBox(height: 15),

                if (loading)
                  const CircularProgressIndicator()
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: saveTicket,
                          child: const Text("Save"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: shareTicket,
                          child: const Text("Share"),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}