import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Map<String, dynamic>> allFlights = [];
  Map<String, double> countryStats = {};

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    final prefs = await SharedPreferences.getInstance();
    final upcomingFlights = prefs.getStringList('flights') ?? [];
    final pastFlights = prefs.getStringList('past_flights') ?? [];

    setState(() {
      allFlights = [
        ...upcomingFlights.map((f) => json.decode(f)),
        ...pastFlights.map((f) => json.decode(f))
      ];
      _calculateCountryStats();
    });
  }

  void _calculateCountryStats() {
    Map<String, int> countryCount = {};
    for (var flight in allFlights) {
      String country = flight['arrival'].toString().split(',').last.trim();
      countryCount[country] = (countryCount[country] ?? 0) + 1;
    }

    int totalFlights = countryCount.values.fold(0, (sum, count) => sum + count);
    countryStats = countryCount.map(
        (country, count) => MapEntry(country, (count / totalFlights) * 100));
  }

  double _calculateTotalCost() {
    return allFlights.fold(
        0.0, (sum, flight) => sum + double.parse(flight['price'].toString()));
  }

  double _calculateTotalHours() {
    return allFlights.fold(0.0, (sum, flight) {
      String duration = flight['duration'];
      double hours = double.parse(duration.split('h').first);
      if (duration.contains('m')) {
        double minutes =
            double.parse(duration.split('/').last.split('m').first) / 60;
        hours += minutes;
      }
      return sum + hours;
    });
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    String? subtitle,
    Widget? chart,
    List<MapEntry<String, double>>? listItems,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.concertOne(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFFD13438),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.concertOne(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.concertOne(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
            if (chart != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: chart,
              ),
            ],
            if (listItems != null) ...[
              const SizedBox(height: 16),
              ...listItems.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD13438),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: GoogleFonts.concertOne(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(0)}%',
                          style: GoogleFonts.concertOne(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = _calculateTotalCost();
    final totalHours = _calculateTotalHours();
    final countriesSorted = countryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD13438)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your stats',
          style: GoogleFonts.concertOne(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildStatsCard(
            title: 'Total flights',
            value: allFlights.length.toString(),
          ),
          _buildStatsCard(
            title: 'Total cost',
            value: '\$${totalCost.toStringAsFixed(0)}',
            subtitle: '+22% taxes',
            chart: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: ChartPainter(allFlights
                  .map((f) => double.parse(f['price'].toString()))
                  .toList()),
            ),
          ),
          _buildStatsCard(
            title: 'Total hours',
            value: '${totalHours.toStringAsFixed(0)} h',
          ),
          _buildStatsCard(
            title: 'Most visited\ncountries',
            value: '',
            listItems: countriesSorted.take(3).toList(),
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> values;

  ChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD13438)
      ..style = PaintingStyle.fill;

    if (values.isEmpty) return;

    final maxValue = values.reduce((curr, next) => curr > next ? curr : next);
    final width = size.width / (values.length * 2 - 1);

    for (int i = 0; i < values.length; i++) {
      final height = (values[i] / maxValue) * size.height;
      final rect = Rect.fromLTWH(
        i * width * 2,
        size.height - height,
        width,
        height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
