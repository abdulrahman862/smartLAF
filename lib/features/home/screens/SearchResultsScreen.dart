import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<String> locations;
  final String? category;
  final DateTime? fromDate;
  final DateTime? toDate;

  const SearchResultsScreen({
    super.key,
    required this.locations,
    this.category,
    this.fromDate,
    this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filtered Results')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 Locations: ${locations.isEmpty ? "Any" : locations.join(", ")}'),
            const SizedBox(height: 10),
            Text('📦 Category: ${category ?? "Any"}'),
            const SizedBox(height: 10),
            Text('📅 From: ${fromDate?.toLocal().toString().split(' ')[0] ?? "Any"}'),
            Text('📅 To: ${toDate?.toLocal().toString().split(' ')[0] ?? "Any"}'),
            const SizedBox(height: 30),
            const Text('Filtered results would appear here...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
