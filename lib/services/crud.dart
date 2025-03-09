import 'dart:async';

import 'package:ireport/services/auth/supabase.dart';
import 'package:supabase/supabase.dart';

class CrudService {
  SupabaseClient _client;

  CrudService(this._client);

  Future<void> initialize() async {
    await SupabaseService.initialize();
  }

  Future<bool> insertReport(Map<String, dynamic> reportData) async {
    final response = await _client.from('reports').insert(reportData);

    if (response != null) {
      throw Exception('Failed to insert report: ${response.error!.message}');
    }
    return true;
  }

  // ONLY SELECT DATA NOT EQUAL TO RESOLVED
  Stream<List<Map<String, dynamic>>> getRecentReports() {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    void fetchReports() async {
      final reports = await _client
          .from('reports')
          .select('*')
          .neq('status', 'resolved')
          .order('created_at', ascending: false);

      controller.add(reports
          .where((report) => DateTime.parse(report['created_at'])
              .isAfter(DateTime.now().subtract(const Duration(days: 1))))
          .toList());
    }

    // Initial fetch
    fetchReports();

    // Listen to real-time changes
    final subscription =
        _client.from('reports').stream(primaryKey: ['id']).listen((snapshot) {
      fetchReports(); // Refetch reports on insert, update, delete
    });

    return controller.stream;
  }

  Future<bool> updateReportStatus(String reportId, String newStatus) async {
    try {
      final response = await _client
          .from('reports')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', reportId)
          .select();

      if (response.isEmpty) {
        throw Exception('Failed to update report status: $response');
      }
      return true;
    } catch (e) {
      throw Exception('Exception caught in updateReportStatus: $e');
    }
  }

  Future<List<String>> getReportStatuses() async {
    try {
      final response = await _client.from('reports').select('status');

      if (response == null) {
        throw Exception('Failed to fetch report statuses');
      }

      return response.map<String>((report) => report['status'] as String).toList();
    } catch (e) {
      throw Exception('Exception caught in getReportStatuses: $e');
    }
  }
}


