import 'package:ireport/services/auth/supabase.dart';
import 'package:supabase/supabase.dart';
class CrudService {
  SupabaseClient _client;

  CrudService(this._client);

  Future<void> initialize() async {
    await SupabaseService.initialize();
  }

  Future<bool> insertReport(Map<String, dynamic> reportData) async {
    final response = await _client
        .from('reports')
        .insert(reportData);

    if (response != null) {
      throw Exception('Failed to insert report: ${response.error!.message}');
    }
    return true;
  }
}