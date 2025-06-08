import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserIncidentView extends StatefulWidget {
  const UserIncidentView({super.key});

  @override
  State<UserIncidentView> createState() => _UserIncidentViewState();
}

class _UserIncidentViewState extends State<UserIncidentView> {
  late String status;

  bool _isMapInitialized = false;

  bool loading = true;

  late GoogleMapController mapsController;
  final Set<Marker> _markers = {};

  late LatLng _initialMapCenter;
  late double _Latitude;
  late double _Longitude;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isMapInitialized) {
      final Map<String, dynamic> args =
          (GoRouterState.of(context).extra ?? {}) as Map<String, dynamic>;

      _Latitude = (args['latitude'] as double?) ?? 0.0;
      _Longitude = (args['longitude'] as double?) ?? 0.0;

      _initialMapCenter = LatLng(_Latitude, _Longitude);

      _addMarkers();

      _isMapInitialized = true; // Set flag to true to prevent re-initialization
    }
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

  void _addMarkers() {
    setState(() {
      _markers.clear();

      _markers.add(
        Marker(
          markerId: MarkerId(
              _Latitude.toString() + _Longitude.toString()), // Unique marker ID
          position: LatLng(_Latitude, _Longitude),
          infoWindow: const InfoWindow(
            title: 'Exact Location',
            snippet: 'GPS Location',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        (GoRouterState.of(context).extra ?? {}) as Map<String, dynamic>;
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
                Text(
                    'Coordinates: Latitude ${args['latitude'] ?? 'Unknown'}, Longitude ${args['longitude'] ?? 'Unknown'}'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapsController = controller;
                      // Animate to the location after map is created
                      mapsController.animateCamera(
                        CameraUpdate.newLatLngZoom(_initialMapCenter, 15.0),
                      );
                    },
                    initialCameraPosition: CameraPosition(
                      target:
                          _initialMapCenter, // initial camera to the extracted location
                      zoom: 15.0, // Adjust zoom level as needed
                    ),
                    markers:
                        _markers, // Display markers from the _locations list
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false,
                  ), 
                ),
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
