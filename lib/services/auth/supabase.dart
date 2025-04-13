import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  SupabaseService._internal();


  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String anonKey = dotenv.env['SUPABASE_ANONKEY'] ?? ''; 

  final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
    );
  }

   Future<AuthSessionUrlResponse?> getSessionFromUrl(Uri uri) async {
  try {
    final response = await client.auth.getSessionFromUrl(uri);
    return response;
  } catch (e) {
    print('Error getting session from URL: $e');
    return null;
  }
}
}
