import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ireport/services/auth/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';

class CrudService {
  SupabaseClient _client;

  CrudService(this._client);

  Future<void> initialize() async {
    await SupabaseService.initialize();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      final Map<String, dynamic> userMap =
          jsonDecode(userJson) as Map<String, dynamic>;
      return userMap['id'] as String?;
    }
    return null;
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
              .isAfter(DateTime.now().subtract(const Duration(days: 2))))
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

  // FETCH USER REPORT BY ID
  Stream<List<Map<String, dynamic>>> getAllReportsByUser() {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    void fetchReports() async {
      try {
        final userId = await getUserId();
        if (userId == null) {
          throw Exception('User ID not found in preferences');
        }

        final reports = await _client
            .from('reports')
            .select('*')
            .eq('reported_by', userId)
            .order('created_at', ascending: false);

        controller.add(reports);
      } catch (e) {
        controller.addError('Failed to fetch reports: $e');
      }
    }

    // Initial fetch
    fetchReports();

    // Listen to real-time changes
    final subscription =
        _client.from('reports').stream(primaryKey: ['id']).listen((snapshot) {
      fetchReports();
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

  Stream<List<String>> getReportStatuses() {
    final controller = StreamController<List<String>>.broadcast();

    void fetchStatuses() async {
      try {
        final response = await _client.from('reports').select('status');

        if (response == null) {
          throw Exception('Failed to fetch report statuses');
        }

        controller.add(response
            .map<String>((report) => report['status'] as String)
            .toList());
      } catch (e) {
        controller.addError('Exception caught in getReportStatuses: $e');
      }
    }

    // Initial fetch
    fetchStatuses();

    // Listen to real-time changes
    final subscription =
        _client.from('reports').stream(primaryKey: ['id']).listen((snapshot) {
      fetchStatuses();
    });

    return controller.stream;
  }

  Future<bool> uploadFile(File file, String fileName) async {
    try {
      final response = await _client.storage.from('ireport').upload(
          fileName, file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'));

      if (response == null) {
        throw Exception('Failed to upload file: $response');
      }

      return true;
    } catch (e) {
      throw Exception('Exception caught in uploadFile: $e');
    }
  }

  Future<String> getImageFile(String fileName) async {
    try {
      final response =
          await _client.storage.from('ireport').getPublicUrl(fileName);

      if (response == null) {
        throw Exception('Failed to download file: $response');
      }

      return response;
    } catch (e) {
      throw Exception('Exception caught in downloadFile: $e');
    }
  }

  Future<bool> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await _client.auth.signUp(
          password: userData['password'],
          email: userData['email'],
          emailRedirectTo: 'ireport://ireport/email-confirmed',
          data: {
            'first_name': userData['first_name'],
            'last_name': userData['last_name'],
            'phone_number': userData['phone_number'],
            'role': 'user'
          });

      final Session? session = response.session;
      final User? user = response.user;

    } on AuthException catch (e) {
      if (e.message.contains('Email is already registered.')) {
        throw Exception('Email is already registered.');
      }
      throw Exception('${e.message}');
    } catch (error) {
      throw Exception('Unexpected error: $error');
    }
    return true;
  }

  Future<bool> registerAdmin(Map<String, dynamic> userData) async {
    try {
      final response = await _client.auth
          .signUp(password: userData['password'], email: userData['email'], emailRedirectTo: 'ireport://ireport/email-confirmed',);

      final Session? session = response.session;
      final User? user = response.user;

    } on AuthException catch (e) {
      if (e.message.contains('Email is already registered.')) {
        throw Exception('Email is already registered.');
      }
      throw Exception('${e.message}');
    } catch (error) {
      throw Exception('Unexpected error: $error');
    }
    return true;
  }

  Future<Session?> getCurrentSession() async {
    try {
      final session = _client.auth.currentSession;
      return session;
    } catch (e) {
      throw Exception('Failed to get current session: $e');
    }
  }
}
