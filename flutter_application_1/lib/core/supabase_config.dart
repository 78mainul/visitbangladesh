import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future init() async {
    await Supabase.initialize(
      url: 'https://gfzaqvouvptozxrygkzo.supabase.co',
      anonKey: 'sb_publishable_TsBPa4xLikXVGQkWSV8FGQ_vYAOYqyu',
    );
  }
}
