import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {

  Future<List<dynamic>> fetchGuides() async {
    try {
      final response = await SupabaseService.client
          .from('guides')
          .select();

      debugPrint("GUIDES DATA: $response");

      return response;
    } catch (e) {
      debugPrint("ERROR: $e");
      rethrow;
    }
  }

  Widget buildGuideCard(
  dynamic item,
  Color backgroundColor,
  Color iconColor,
  IconData icon,
) {
  return Card(
    color: backgroundColor,
    elevation: 3,

    margin: const EdgeInsets.only(bottom: 12),

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),

    child: ExpansionTile(

      leading: Icon(
        icon,
        color: iconColor,
        size: 32,
      ),

      title: Text(
        item['item_name'] ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      subtitle: Text(
        item['category'] ?? '',
        style: const TextStyle(
          fontSize: 15,
        ),
      ),

      children: [

        Padding(
          padding: const EdgeInsets.all(16),

          child: Text(
            item['instructions'] ?? '',
            style: const TextStyle(
              height: 1.6,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Guide'),
        centerTitle: true,
      ),

      body: FutureBuilder<List<dynamic>>(
  future: fetchGuides(),

  builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Text('Error: ${snapshot.error}'),
      );
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(
        child: Text('No guides found'),
      );
    }

    final guides = snapshot.data!;

    // SPLIT DATA
    final recyclableItems =
        guides.where((item) => item['recyclable'] == true).toList();

    final nonRecyclableItems =
        guides.where((item) => item['recyclable'] == false).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // RECYCLABLE SECTION
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  'Recyclable',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...recyclableItems.map(
              (item) => buildGuideCard(
                item,
                Colors.green.shade50,
                Colors.green,
                Icons.recycling,
              ),
            ),

            const SizedBox(height: 30),

            // NON RECYCLABLE SECTION
            const Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  'Non-Recyclable',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...nonRecyclableItems.map(
              (item) => buildGuideCard(
                item,
                Colors.red.shade50,
                Colors.red,
                Icons.delete,
              ),
            ),
          ],
        ),
      ),
    );
  },
),
    );
  }
}