import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/destination.dart';

class BookingService {
  final client = Supabase.instance.client;

  Future<List<Destination>> getDestinations() async {
    try {
      final data = await client.from('destinations').select();
      print('DESTINATION DATA: $data');

      return (data as List)
          .map((e) => Destination.fromMap(e))
          .toList();
    } catch (e) {
      print('DESTINATION ERROR: $e');
      return [];
    }
  }
}
