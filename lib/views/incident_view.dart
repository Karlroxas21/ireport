import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ireport/services/auth/supabase.dart';
import 'package:ireport/services/crud.dart'; // Import the crud.dart file

class IncidentView extends StatefulWidget {
  const IncidentView({super.key});

  @override
  State<IncidentView> createState() => _IncidentViewState();
}

class _IncidentViewState extends State<IncidentView> {
  late String status;
  late String newStatus;
  late final Map<String, dynamic> args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

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

  late final CrudService crudService = CrudService(SupabaseService().client);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    try {
      if (newStatus != args['status']) {
        crudService.updateReportStatus(
            args['id'].toString(), newStatus.toLowerCase());
        
      }
    } catch (e) {
      throw Exception(e);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    status = (args['status'] ?? '')
        .toString()
        .toUpperCase(); // Ensure status is a String

    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize
                  .min, // This makes the column height relative to its content
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${args['title'] ?? 'Unknown'}'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(args['status'] ?? 'Unknown'),
                          color: _getStatusColor(args['status'] ?? 'Unknown'),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${args['status'] ?? 'Unknown'}'.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(args['status'] ?? 'Unknown'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    'Date: ${args['created_at'] != null ? DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.parse(args['created_at']).toLocal()) : 'Unknown'}'),
                const SizedBox(height: 8),
                Text('Location: ${args['location'] ?? 'Unknown'}'),
                const SizedBox(height: 16),
                Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${args['description'] ?? 'Unknown'}'),
                const SizedBox(height: 16),
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${args['status'] ?? 'Unknown'}'.toUpperCase()),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                const Text(
                  'Update Status:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: status,
                    items: <String>[
                      'IN-PROGRESS',
                      'PENDING',
                      'CRITICAL',
                      'RESOLVED',
                    ]
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        newStatus = value!.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                      hoverColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an incident type';
                      }
                      return null;
                    },
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
