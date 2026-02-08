import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination.dart';

class BookingService {
  final client = Supabase.instance.client;

  Future<List<Destination>> getDestinations() async {
    final data = await client.from('destinations').select();
    return (data as List)
        .map((e) => Destination.fromMap(e))
        .toList();
  }
}
