import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class UserIncidentView extends StatefulWidget {
  const UserIncidentView({super.key});

  @override
  State<UserIncidentView> createState() => _UserIncidentViewState();
}

class _UserIncidentViewState extends State<UserIncidentView> {
  late String status;
  late final Map<String, dynamic> args = (GoRouterState.of(context).extra ?? {}) as Map<String, dynamic>;
  bool loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
      appBar: AppBar(
        title: Text('Back'),
      ),
      body: SingleChildScrollView(
        child: Container(
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
              mainAxisSize: MainAxisSize.min,
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
                          // TODO: status not fetching
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
                  'Name:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    '${(args['name'] ?? '').isEmpty ? 'Unknown' : args['name']}'),
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
                  'Status:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (args['image_url'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(),
                              body: Center(
                                child: Image.network(
                                  args['image_url'],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: args['image_url'] != null
                        ? Stack(
                            children: [
                              Image.network(
                                args['image_url'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                frameBuilder: (BuildContext context,
                                    Widget child,
                                    int? frame,
                                    bool wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded || frame != null) {
                                    loading = false;
                                    return child;
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'No Image Available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
