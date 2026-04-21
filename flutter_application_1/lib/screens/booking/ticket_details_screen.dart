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
  final ScreenshotController _controller = ScreenshotController();
  bool _loading = false;

  String get qrData =>
      "Destination: ${widget.destination}\nTickets: ${widget.tickets}\nTotal: ৳${widget.total}";

  Future<Uint8List?> _capture() async {
    try {
      return await _controller.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveTicket() async {
    setState(() => _loading = true);

    try {
      final image = await _capture();
      if (image == null) return;

      final dir = await getApplicationDocumentsDirectory();

      final file = File(
        '${dir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(image);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket saved successfully ✅")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save ticket ❌")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _shareTicket() async {
    setState(() => _loading = true);

    try {
      final image = await _capture();
      if (image == null) return;

      final xfile = XFile.fromData(
        image,
        name: 'ticket.png',
        mimeType: 'image/png',
      );

      await Share.shareXFiles(
        [xfile],
        text: "🎫 My Ticket - ${widget.destination}",
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Share failed ❌")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text("Digital Ticket"),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: Center(
        child: Screenshot(
          controller: _controller,
          child: _TicketCard(
            destination: widget.destination,
            tickets: widget.tickets,
            total: widget.total,
            qrData: qrData,
            loading: _loading,
            onDownload: _saveTicket,
            onShare: _shareTicket,
          ),
        ),
      ),
    );
  }
}

/* ---------------- PREMIUM TICKET UI ---------------- */

class _TicketCard extends StatelessWidget {
  final String destination;
  final int tickets;
  final int total;
  final String qrData;
  final bool loading;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const _TicketCard({
    required this.destination,
    required this.tickets,
    required this.total,
    required this.qrData,
    required this.loading,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.airplane_ticket,
              color: Colors.white, size: 40),

          const SizedBox(height: 10),

          Text(
            destination,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoBox("Tickets", "$tickets"),
              _infoBox("Total", "৳$total"),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: qrData,
              size: 180,
            ),
          ),

          const SizedBox(height: 20),

          if (loading)
            const CircularProgressIndicator(color: Colors.white)
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text("Save"),
                    onPressed: onDownload,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                    onPressed: onShare,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}