import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/destination.dart';
import '../booking/booking_screen.dart';

class DestinationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> destination;

  const DestinationDetailsPage({
    super.key,
    required this.destination,
  });

  Future<void> _openLocation(
    double? latitude,
    double? longitude,
    String location,
  ) async {
    Uri url;

    if (latitude != null && longitude != null) {
      url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
    } else {
      url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
      );
    }

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = destination['name'] ?? 'Unknown';
    final location = destination['location'] ?? '';
    final description = destination['description'] ?? '';

    final image = destination['image_url'] ??
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470';

    final latitude = destination['lat'] != null
        ? double.tryParse(destination['lat'].toString())
        : null;

    final longitude = destination['lng'] != null
        ? double.tryParse(destination['lng'].toString())
        : null;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),

      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HERO IMAGE
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: Image.network(
                        image,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          );
                        },
                      ),
                    ),

                    Container(
                      height: 250,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard(location, latitude, longitude),

                      const SizedBox(height: 16),

                      const Text(
                        "About",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        description.isEmpty
                            ? "No description available"
                            : description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ MAP ADDED HERE
                      if (latitude != null && longitude != null) ...[
                        const Text(
                          "Location",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                latitude,
                                longitude,
                              ),
                              initialZoom: 14,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.flutter_application_1',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      latitude,
                                      longitude,
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BOOK NOW BUTTON
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          destination: Destination.fromMap(destination),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    String location,
    double? latitude,
    double? longitude,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () => _openLocation(
              latitude,
              longitude,
              location,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                const Icon(Icons.place, color: Colors.green),
                const SizedBox(height: 4),
                Text(
                  latitude != null && longitude != null
                      ? "View Map"
                      : "Location",
                ),
              ],
            ),
          ),

          const _InfoItem(icon: Icons.star, label: "4.8"),
          const _InfoItem(icon: Icons.lock_clock, label: "Open"),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}