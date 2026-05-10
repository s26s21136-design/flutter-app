import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  Future<void> addBin({
  required String locationName,
  required double latitude,
  required double longitude,
  required String binType,
}) async {
  try {
    await SupabaseService.client.from('bins').insert({
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'bin_type': binType,
    });

    fetchBins();
  } catch (e) {
    debugPrint('Error adding bin: $e');
  }
}

void showAddDialog() {
  final nameController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  String selectedType = 'recycling';

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Bin"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Location Name',
                    ),
                  ),

                  TextField(
                    controller: latController,
                    keyboardType:
                        TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                    ),
                  ),

                  TextField(
                    controller: lngController,
                    keyboardType:
                        TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'general',
                        child: Text('General'),
                      ),
                      DropdownMenuItem(
                        value: 'plastic',
                        child: Text('Plastic'),
                      ),
                      DropdownMenuItem(
                        value: 'paper',
                        child: Text('Paper'),
                      ),
                      DropdownMenuItem(
                        value: 'recycling',
                        child: Text('Recycling'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              ElevatedButton(
                onPressed: () async {
                  await addBin(
                    locationName: nameController.text,
                    latitude:
                        double.tryParse(latController.text) ?? 0,
                    longitude:
                        double.tryParse(lngController.text) ?? 0,
                    binType: selectedType,
                  );

                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> updateBin({
  required String id,
  required String locationName,
  required String binType,
}) async {
  try {
    await SupabaseService.client
        .from('bins')
        .update({
          'location_name': locationName,
          'bin_type': binType,
        })
        .eq('id', id);

    fetchBins();
  } catch (e) {
    debugPrint('Error updating bin: $e');
  }
}

Future<void> deleteBin(String id) async {
  try {
    await SupabaseService.client
        .from('bins')
        .delete()
        .eq('id', id);

    fetchBins();
  } catch (e) {
    debugPrint('Error deleting bin: $e');
  }
}

void showEditDialog({
  required String id,
  required String currentName,
  required String currentType,
}) {
  final nameController =
      TextEditingController(text: currentName);

  String selectedType = currentType;

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Bin"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'general',
                      child: Text('General'),
                    ),
                    DropdownMenuItem(
                      value: 'plastic',
                      child: Text('Plastic'),
                    ),
                    DropdownMenuItem(
                      value: 'paper',
                      child: Text('Paper'),
                    ),
                    DropdownMenuItem(
                      value: 'recycling',
                      child: Text('Recycling'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              ElevatedButton(
                onPressed: () async {
                  await updateBin(
                    id: id,
                    locationName: nameController.text,
                    binType: selectedType,
                  );

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> openMaps(double lat, double lng) async {
  final url = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch Maps';
  }
}
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    fetchBins();
  }
 
  Future<void> fetchBins() async {
  try {
    final response = await SupabaseService.client
        .from('bins')
        .select();

    final List data = response;

    final loadedMarkers = data.map((bin) {
      final String id = bin['id'] ?? 0;
      final double latitude =
          double.tryParse(bin['latitude'].toString()) ?? 0;

      final double longitude =
          double.tryParse(bin['longitude'].toString()) ?? 0;

      // get type from database
      final String type =
          (bin['bin_type'] ?? 'recycling').toString();

      // default values
      Color markerColor = Colors.green;
      IconData markerIcon = Icons.recycling;
      String title = 'Recycling Bin';

      // different bins
      if (type == 'general') {
        markerColor = Colors.red;
        markerIcon = Icons.delete;
        title = 'General Waste Bin';
      } else if (type == 'plastic') {
        markerColor = Colors.blue;
        markerIcon = Icons.local_drink;
        title = 'Plastic Recycling Bin';
      } else if (type == 'paper') {
        markerColor = Colors.yellow;
        markerIcon = Icons.description;
        title = 'Paper Recycling Bin';
      }

      return Marker(
        point: LatLng(latitude, longitude),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text(title),
                    content: Text(
                      bin['location_name'] ?? 'Waste collection point available here.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          openMaps(latitude, longitude);
                        },
                        child: const Text("Navigate"),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () {
                          Navigator.pop(context);

                          showEditDialog(
                            id: id,
                            currentName: bin['location_name'],
                            currentType: type,
                          );
                        },
                        child: const Text("Edit"),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await deleteBin(id);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
    );
  },
);
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  markerIcon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    setState(() {
      markers = loadedMarkers;
    });
  } catch (e) {
    debugPrint('Error fetching bins: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Recycling Bins'),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(23.5880, 58.3829),
          initialZoom: 11,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.reloopoman.app',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      heroTag: "refresh",
      backgroundColor: Colors.green,
      onPressed: fetchBins,
      child: const Icon(Icons.refresh),
    ),

    const SizedBox(height: 12),

    FloatingActionButton(
      heroTag: "add",
      backgroundColor: Colors.blue,
      onPressed: showAddDialog,
      child: const Icon(Icons.add),
    ),
  ],
),
    );
  }
}