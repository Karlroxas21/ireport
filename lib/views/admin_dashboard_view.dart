import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ireport/enums/incident_categories.dart';
import 'package:ireport/enums/menu_action.dart';
import 'package:ireport/services/auth/supabase.dart';
import 'package:ireport/services/crud.dart';
import 'package:intl/intl.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;
  TextEditingController searchController = TextEditingController();

  late final CrudService _crudService = CrudService(SupabaseService().client);
  List<Map<String, dynamic>> reportList = [];
  List<Map<String, dynamic>> filteredReports = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(filterReports);
    fetchReports();
  }

  void fetchReports() async {
    final reports = await _crudService.getRecentReports().first;
    setState(() {
      reportList = reports;
      filteredReports = List.from(reportList);
    });
  }

  void filterReports() {
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredReports = List.from(reportList);
      } else {
        filteredReports = reportList.where((report) {
          return (report['title'] ?? '').toLowerCase().contains(query) ||
              (report['status'] ?? '').toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'IN-PROGRESS':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'IN-PROGRESS':
        return Icons.autorenew;
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'CRITICAL':
        return Icons.error;
      case 'RESOLVED':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 8, right: 8),
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "iReport Admin Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text("View and manage all reported incidents"),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search Incidents...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _crudService.getRecentReports(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reports = snapshot.data!;
                  final filteredReports = reports.where((report) {
                    final query = searchController.text.toLowerCase();
                    return (report['title'] ?? '')
                            .toLowerCase()
                            .contains(query) ||
                        (report['status'] ?? '').toLowerCase().contains(query);
                  }).toList();

                  if (filteredReports.isEmpty) {
                    return const Center(child: Text("No reports found"));
                  }

                  return ListView.builder(
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      final createdAt =
                          DateTime.parse(report['created_at']).toLocal();
                      final formattedTime =
                          DateFormat('yyyy-MM-dd hh:mm a').format(createdAt);

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            report['title'] ?? 'No Title',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Location: ${report['location'] ?? 'No Location'}'),
                              Text('Time: $formattedTime'),
                              Text(
                                  'Description: ${report['description'] ?? 'No Details'}'),
                            ],
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  _getStatusIcon(report['status'] ?? 'Unknown'),
                                  color: _getStatusColor(
                                      report['status'] ?? 'Unknown'),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (report['status'] ?? 'Unknown').toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(
                                        report['status'] ?? 'Unknown'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            context.pushNamed(
                              '/incident-view',
                                extra: report,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
