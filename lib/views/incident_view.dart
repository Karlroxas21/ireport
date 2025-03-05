import 'package:flutter/material.dart';

class IncidentView extends StatefulWidget {
  const IncidentView({super.key});

  @override
  State<IncidentView> createState() => _IncidentViewState();
}

class _IncidentViewState extends State<IncidentView> {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    if (args == null || args is! Map<String, String>) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Invalid arguments provided'),
        ),
      );
    }
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Incident',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'In-progress',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Reported Date: ${args['time'] ?? 'Unknown'}'),
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
                const Text('No details available'),
                const SizedBox(height: 16),
                const Text(
                  'Timeline:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Incident reported'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Investigation started'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Critical issue found'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Issue resolved'),
                      ],
                    ),
                  ],
                ),
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
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: 'In-progress',
                      items: <String>[
                        'In-progress',
                        'Pending',
                        'Critical',
                        'Resolve'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Handle status update logic here
                      },
                      dropdownColor:
                          Colors.white, // Set the dropdown background color
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
