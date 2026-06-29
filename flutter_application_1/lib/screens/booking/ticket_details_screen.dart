
// 📦 Dart core library (ফাইল সেভ/স্টোরেজের জন্য)
import 'dart:io';

// 🎯 Flutter UI framework (অ্যাপের UI বানানোর জন্য)
import 'package:flutter/material.dart';

// 📸 স্ক্রিনশট নেওয়ার জন্য প্যাকেজ
import 'package:screenshot/screenshot.dart';

// 📊 QR কোড তৈরি করার জন্য
import 'package:qr_flutter/qr_flutter.dart';

// 📁 মোবাইলের storage access করার জন্য
import 'package:path_provider/path_provider.dart';

// 📄 PDF তৈরি করার জন্য
import 'package:pdf/widgets.dart' as pw;

// 🖨️ PDF শেয়ার/প্রিন্ট করার জন্য
import 'package:printing/printing.dart';

// ☁️ Supabase backend (ডাটাবেস)
import 'package:supabase_flutter/supabase_flutter.dart';


/* =========================================================
   🎫 TICKET MODEL (ডাটার কাঠামো)
   এখানে টিকিটের সব তথ্য রাখা হয়
========================================================= */
class TicketModel {
  final String userName;        // 👤 ইউজারের নাম
  final String mobile;          // 📞 ইউজারের মোবাইল

  final String destinationName; // 📍 গন্তব্যের নাম
  final String location;        // 🌍 লোকেশন

  final double price;           // 💰 এক টিকিটের দাম
  final int quantity;           // 🎟️ কয়টা টিকিট
  final double totalPrice;      // 💵 মোট দাম

  final String travelDate;      // 📅 যাত্রার তারিখ
  final String bookedAt;        // ⏰ বুক করার সময়

  final String ticketId;        // 🆔 টিকিট ID

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


/* =========================================================
   ☁️ TICKET SERVICE (Supabase থেকে ডাটা আনা)
========================================================= */
class TicketService {
  final supabase = Supabase.instance.client;

  /* 🎫 নির্দিষ্ট ticketId দিয়ে ডাটা আনা */
  Future<TicketModel?> getTicket(String ticketId) async {
    try {

      // 🔥 Supabase থেকে tickets table query করা হচ্ছে
      // এখানে users + destinations টেবিল join করা হয়েছে
      final response = await supabase
          .from('tickets')
          .select('*, users(name, mobile), destinations(name, location, price)')
          .eq('id', ticketId)
          .maybeSingle();

      // ❌ যদি কোনো ডাটা না পাওয়া যায়
      if (response == null) return null;

      // ✅ Supabase response থেকে Model তৈরি করা হচ্ছে
      return TicketModel(
        userName: response['users']?['name'] ?? "",   // 👤 user name
        mobile: response['users']?['mobile'] ?? "",   // 📞 mobile

        destinationName: response['destinations']?['name'] ?? "", // 📍 destination
        location: response['destinations']?['location'] ?? "",    // 🌍 location

        price: double.tryParse(
              response['destinations']?['price']?.toString() ?? "0",
            ) ??
            0.0, // 💰 price safe convert

        quantity: int.tryParse(
              response['tickets_count']?.toString() ?? "0",
            ) ??
            0, // 🎟️ quantity safe convert

        totalPrice: double.tryParse(
              response['total_price']?.toString() ?? "0",
            ) ??
            0.0, // 💵 total price

        travelDate: response['travel_date'] ?? "", // 📅 date
        bookedAt: response['booked_at'] ?? "",     // ⏰ booked time
        ticketId: response['id'],                  // 🆔 id
      );

    } catch (e) {
      // ❗ কোনো error হলে এখানে আসবে
      debugPrint("Supabase error: $e");
      return null;
    }
  }
}


/* =========================================================
   🎫 TICKET DETAILS SCREEN (UI PAGE)
========================================================= */
class TicketDetailsScreen extends StatefulWidget {
  final String ticketId; // কোন ticket দেখাতে হবে

  const TicketDetailsScreen({
    super.key,
    required this.ticketId,
  });

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}


class _TicketDetailsScreenState extends State<TicketDetailsScreen> {

  // 📸 স্ক্রিনশট controller
  final ScreenshotController screenshotController = ScreenshotController();

  // ☁️ service object
  final service = TicketService();

  TicketModel? ticket; // 📦 টিকিট ডাটা
  bool loading = true; // ⏳ লোডিং স্টেট

  @override
  void initState() {
    super.initState();

    // 🚀 স্ক্রিন খুললেই ডাটা লোড হবে
    loadTicket();
  }


  /* 🔄 Supabase থেকে টিকিট লোড করা */
  Future<void> loadTicket() async {
    try {
      ticket = await service.getTicket(widget.ticketId);
    } catch (e) {
      debugPrint("Load error: $e");
      ticket = null;
    } finally {
      if (mounted) {
        setState(() {
          loading = false; // ⏳ লোডিং শেষ
        });
      }
    }
  }


  /* 📊 QR code এর ভিতরে যেই ডাটা যাবে */
  String get qrData => '''
Ticket ID: ${ticket?.ticketId ?? ""}
Name: ${ticket?.userName ?? ""}
Mobile: ${ticket?.mobile ?? ""}
Destination: ${ticket?.destinationName ?? ""}
Date: ${ticket?.travelDate ?? ""}
Total: ${ticket?.totalPrice ?? ""}
''';


  /* 🖼️ টিকিটের ছবি হিসেবে save করা */
  Future<void> saveAsImage() async {

    final image = await screenshotController.capture();

    if (image == null) return;

    // 📁 ফোনের storage path নেওয়া
    final dir = await getApplicationDocumentsDirectory();

    // 📄 ফাইল তৈরি
    final file = File(
      "${dir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png",
    );

    // 💾 ছবি সেভ করা
    await file.writeAsBytes(image);

    // ✅ সফল message দেখানো
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("টিকিট PNG হিসেবে সেভ হয়েছে ✅")),
      );
    }
  }


  /* 📄 PDF বানানো */
  Future<void> generatePdf() async {
    final pdf = pw.Document();

    // 📄 নতুন পেজ তৈরি করা হচ্ছে
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text("🎫 Visit Bangladesh Ticket",
                  style: pw.TextStyle(fontSize: 20)),

              pw.SizedBox(height: 10),

              pw.Text("Name: ${ticket?.userName ?? ""}"),
              pw.Text("Mobile: ${ticket?.mobile ?? ""}"),
              pw.Text("Destination: ${ticket?.destinationName ?? ""}"),
              pw.Text("Location: ${ticket?.location ?? ""}"),
              pw.Text("Price: ${ticket?.price ?? ""}"),
              pw.Text("Quantity: ${ticket?.quantity ?? ""}"),
              pw.Text("Total: ${ticket?.totalPrice ?? ""}"),
              pw.Text("Travel Date: ${ticket?.travelDate ?? ""}"),
              pw.Text("Booked At: ${ticket?.bookedAt ?? ""}"),

              pw.SizedBox(height: 10),

              pw.Text("Terms: Non-refundable | QR required at entry"),
            ],
          );
        },
      ),
    );

    // 📤 PDF শেয়ার করা
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "ticket.pdf",
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // 🎨 ব্যাকগ্রাউন্ড কালার
      backgroundColor: const Color(0xff0f172a),

      appBar: AppBar(
        title: const Text("Ticket Details"),
        backgroundColor: Colors.green,
      ),

      body: loading

          // ⏳ ডাটা লোডিং হলে loading spinner
          ? const Center(child: CircularProgressIndicator())

          // ❌ ডাটা না পেলে message
          : ticket == null
              ? const Center(
                  child: Text(
                    "Ticket পাওয়া যায়নি",
                    style: TextStyle(color: Colors.white),
                  ),
                )

              // 🎫 আসল টিকিট UI
              : Screenshot(
                  controller: screenshotController,

                  child: Center(
                    child: Container(

                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff1e293b), Color(0xff0f172a)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // 👤 ইউজার নাম
                          Text("👤 ${ticket!.userName}",
                              style: const TextStyle(color: Colors.white)),

                          // 📞 মোবাইল
                          Text("📞 ${ticket!.mobile}",
                              style: const TextStyle(color: Colors.white70)),

                          const SizedBox(height: 10),

                          // 📍 ডেস্টিনেশন
                          Text("📍 ${ticket!.destinationName}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20)),

                          // 🌍 লোকেশন
                          Text("Location: ${ticket!.location}",
                              style: const TextStyle(color: Colors.white70)),

                          const SizedBox(height: 10),

                          // 💰 দাম
                          Text("Price: ${ticket!.price}",
                              style: const TextStyle(color: Colors.white)),

                          // 🎟️ কয়টা টিকিট
                          Text("Quantity: ${ticket!.quantity}",
                              style: const TextStyle(color: Colors.white)),

                          // 💵 মোট দাম
                          Text("Total: ${ticket!.totalPrice}",
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold)),

                          const SizedBox(height: 10),

                          // 📊 QR Code
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(8),
                            child: QrImageView(
                              data: qrData,
                              size: 150,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 📥 PNG ডাউনলোড
                          ElevatedButton(
                            onPressed: saveAsImage,
                            child: const Text("Download PNG"),
                          ),

                          // 📄 PDF ডাউনলোড
                          ElevatedButton(
                            onPressed: generatePdf,
                            child: const Text("Download PDF"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}