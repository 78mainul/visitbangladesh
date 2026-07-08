import 'dart:io'; 
// 📁 ফাইল সিস্টেম access করার জন্য (image/pdf save করার কাজে লাগে)

import 'package:flutter/material.dart'; 
// 🎨 Flutter UI বানানোর জন্য মূল framework

import 'package:screenshot/screenshot.dart'; 
// 📸 UI স্ক্রিনকে image হিসেবে capture করার জন্য

import 'package:qr_flutter/qr_flutter.dart'; 
// 📊 QR code generate করার জন্য

import 'package:path_provider/path_provider.dart'; 
// 📁 মোবাইলের internal storage path বের করার জন্য

import 'package:pdf/widgets.dart' as pw; 
// 📄 PDF বানানোর জন্য (pw = pdf widgets alias)

import 'package:printing/printing.dart'; 
// 🖨️ PDF share/print করার জন্য

import 'package:supabase_flutter/supabase_flutter.dart'; 
// ☁️ Supabase backend database access করার জন্য


/* ===================== MODEL ===================== */

class TicketModel {
  // 🎫 Ticket এর সব data structure এখানে define করা হচ্ছে

  final String userName; 
  // 👤 ইউজারের নাম

  final String mobile; 
  // 📞 ইউজারের মোবাইল নাম্বার

  final String destinationName; 
  // 📍 কোথায় যাবে (destination name)

  final String location; 
  // 🌍 লোকেশনের নাম

  final double price; 
  // 💰 এক টিকিটের দাম

  final int quantity; 
  // 🎟️ কয়টা টিকিট নেওয়া হয়েছে

  final double totalPrice; 
  // 💵 মোট দাম

  final String travelDate; 
  // 📅 যাত্রার তারিখ

  final String bookedAt; 
  // ⏰ কখন বুক করা হয়েছে

  final String ticketId; 
  // 🆔 টিকিটের ইউনিক আইডি

  TicketModel({
    required this.userName,
    required this.mobile,
    required this.destinationName,
    required this.location,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.travelDate,
    required this.bookedAt,
    required this.ticketId,
  });
}


/* ===================== SERVICE ===================== */

class TicketService {
  // ☁️ Supabase থেকে data আনার জন্য service class

  final supabase = Supabase.instance.client; 
  // 🔗 Supabase client initialize করা হচ্ছে

  Future<TicketModel?> getTicket(String ticketId) async {
    // 🎫 নির্দিষ্ট ticketId দিয়ে ticket data আনা

    try {
      final response = await supabase
          .from('tickets') 
          // 📂 tickets table থেকে data আনা হচ্ছে

          .select() 
          // 📊 সব column select করা হচ্ছে

          .eq('id', ticketId) 
          // 🔍 নির্দিষ্ট id match করা হচ্ছে

          .maybeSingle(); 
          // 🎯 একটাই row বা null return করবে

      if (response == null) return null; 
      // ❌ data না থাকলে null return

      return TicketModel(
        userName: "", 
        // 👤 এখন userName খালি রাখা হয়েছে (join করা হয়নি)

        mobile: "", 
        // 📞 mobile খালি রাখা হয়েছে

        destinationName: response['destination_name'] ?? "", 
        // 📍 destination name database থেকে আনা হচ্ছে

        location: "", 
        // 🌍 location এখন খালি

        price: 0, 
        // 💰 price এখন default 0

        quantity: int.tryParse(response['tickets_count'].toString()) ?? 0,
        // 🎟️ ticket count safe ভাবে integer এ convert করা হচ্ছে

        totalPrice: double.tryParse(response['total_price'].toString()) ?? 0,
        // 💵 total price safe ভাবে double এ convert করা হচ্ছে

        travelDate: response['travel_date'] ?? "", 
        // 📅 travel date নিচ্ছে

        bookedAt: response['booked_at'] ?? "", 
        // ⏰ booked time নিচ্ছে

        ticketId: response['id'], 
        // 🆔 ticket id সেট করা হচ্ছে
      );

    } catch (e) {
      // ❗ কোনো error হলে এখানে আসবে
      debugPrint("error: $e"); 
      // 🐞 console এ error দেখাবে

      return null; 
      // ❌ error হলে null return
    }
  }
}


/* ===================== SCREEN ===================== */

class TicketDetailsScreen extends StatefulWidget {
  // 📱 Ticket details দেখানোর screen

  final String ticketId; 
  // 🆔 কোন ticket দেখাবে সেটা pass করা হচ্ছে

  const TicketDetailsScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}


/* ===================== STATE ===================== */

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {

  final ScreenshotController controller = ScreenshotController();
  // 📸 screen capture করার controller

  final service = TicketService();
  // ☁️ ticket service object

  TicketModel? ticket;
  // 🎫 ticket data store হবে এখানে

  bool loading = true;
  // ⏳ শুরুতে loading true

  @override
  void initState() {
    super.initState();
    load();
    // 🚀 screen open হলেই data load হবে
  }

  Future<void> load() async {
    ticket = await service.getTicket(widget.ticketId);
    // ☁️ Supabase থেকে ticket data আনা হচ্ছে

    setState(() => loading = false);
    // ⏳ loading শেষ করে UI update
  }


  /* ===================== QR DATA ===================== */

  String get qrData => '''
🎫 Visit Bangladesh Ticket
ID: ${ticket?.ticketId}
Destination: ${ticket?.destinationName}
Date: ${ticket?.travelDate}
Total: ${ticket?.totalPrice}
''';
  // 📊 QR code এর ভিতরে যা data থাকবে


  /* ===================== IMAGE SAVE ===================== */

  Future<void> saveImage() async {
    final img = await controller.capture();
    // 📸 UI কে image হিসেবে capture করা হচ্ছে

    if (img == null) return;
    // ❌ image না পেলে return

    final dir = await getApplicationDocumentsDirectory();
    // 📁 app storage path নেওয়া হচ্ছে

    final file = File("${dir.path}/ticket_${ticket!.ticketId}.png");
    // 📄 file create করা হচ্ছে

    await file.writeAsBytes(img);
    // 💾 image save করা হচ্ছে

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved Successfully")),
    );
    // ✅ success message দেখানো হচ্ছে
  }


  /* ===================== PDF GENERATE ===================== */

  Future<void> generatePdf() async {
    final pdf = pw.Document();
    // 📄 নতুন PDF document তৈরি

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            // 📦 PDF layout padding

            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              // 📄 border draw করা হচ্ছে

              borderRadius: pw.BorderRadius.circular(10),
              // 🔲 rounded corner
            ),

            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              // 📊 left aligned content

              children: [

                pw.Text(
                  "🎫 VISIT BANGLADESH TOUR TICKET",
                  // 🧾 PDF title
                  style: pw.TextStyle(fontSize: 18),
                ),

                pw.Divider(),
                // ➖ line separator

                pw.Text("Destination: ${ticket?.destinationName}"),
                // 📍 destination show

                pw.Text("Travel Date: ${ticket?.travelDate}"),
                // 📅 date show

                pw.Text("Price: ${ticket?.totalPrice}"),
                // 💰 price show

                pw.Text("Quantity: ${ticket?.quantity}"),
                // 🎟️ ticket count

                pw.SizedBox(height: 20),
                // 📏 space

                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    // 📊 QR code PDF এর ভিতরে তৈরি

                    data: qrData,
                    // 🔗 QR data

                    width: 120,
                    height: 120,
                  ),
                ),

                pw.SizedBox(height: 20),
                // 📏 space

                pw.Text(
                  "⚠️ Non-refundable ticket | Show QR at entry",
                  // ⚠️ warning text
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "tour_ticket.pdf",
      // 📤 PDF share করা হচ্ছে
    );
  }


  /* ===================== UI ===================== */

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      // 🎨 screen background color

      appBar: AppBar(
        title: const Text("Tour Ticket"),
        // 📱 top bar title

        backgroundColor: Colors.green,
        // 🎨 appbar color
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          // ⏳ loading spinner

          : ticket == null
              ? const Center(child: Text("Ticket Not Found"))
              // ❌ data না পেলে message

              : Screenshot(
                  controller: controller,
                  // 📸 screenshot enable

                  child: Center(
                    child: Container(

                      margin: const EdgeInsets.all(16),
                      // 📦 বাইরে space

                      padding: const EdgeInsets.all(20),
                      // 📦 ভিতরে space

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff1e293b), Color(0xff0f172a)],
                        ),
                        // 🎨 gradient background

                        borderRadius: BorderRadius.circular(20),
                        // 🔲 rounded corner
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        // 📏 content auto size

                        children: [

                          const Text(
                            "✈️ TOUR TICKET",
                            // 🎫 title text
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),
                          // 📏 spacing

                          Text("Destination: ${ticket!.destinationName}",
                              style: const TextStyle(color: Colors.white)),
                          // 📍 destination show

                          Text("Date: ${ticket!.travelDate}",
                              style: const TextStyle(color: Colors.white70)),
                          // 📅 date show

                          Text("Total: ৳${ticket!.totalPrice}",
                              style: const TextStyle(color: Colors.greenAccent)),
                          // 💰 total price

                          const SizedBox(height: 15),
                          // 📏 spacing

                          Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors.white,
                            // 📦 QR box background white

                            child: QrImageView(
                              data: qrData,
                              // 📊 QR data

                              size: 140,
                              // 📏 QR size
                            ),
                          ),

                          const SizedBox(height: 15),
                          // 📏 spacing

                          ElevatedButton.icon(
                            onPressed: saveImage,
                            // 📥 PNG save button

                            icon: const Icon(Icons.download),
                            label: const Text("Download PNG"),
                          ),

                          ElevatedButton.icon(
                            onPressed: generatePdf,
                            // 📄 PDF generate button

                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text("Download PDF"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}