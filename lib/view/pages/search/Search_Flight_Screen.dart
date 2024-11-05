import 'package:flight_list/view/widgets/flight_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SearchFlightsScreen extends StatefulWidget {
  const SearchFlightsScreen({Key? key}) : super(key: key);

  @override
  State<SearchFlightsScreen> createState() => _SearchFlightsScreenState();
}

class _SearchFlightsScreenState extends State<SearchFlightsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allFlights = [];
  List<Map<String, dynamic>> filteredFlights = [];

  @override
  void initState() {
    super.initState();
    _loadAllFlights();
  }

  Future<void> _loadAllFlights() async {
    final prefs = await SharedPreferences.getInstance();
    final upcomingFlights = prefs.getStringList('flights') ?? [];
    final pastFlights = prefs.getStringList('past_flights') ?? [];

    setState(() {
      allFlights = [
        ...upcomingFlights
            .map((f) => {...json.decode(f), 'status': 'upcoming'}),
        ...pastFlights.map((f) => {...json.decode(f), 'status': 'past'}),
      ];
      filteredFlights = List.from(allFlights);
    });
  }

  void _filterFlights(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredFlights = List.from(allFlights);
      });
      return;
    }

    setState(() {
      filteredFlights = allFlights.where((flight) {
        final arrival = flight['arrival'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return arrival.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Search Flights',
          style: GoogleFonts.concertOne(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD13438)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterFlights,
              style: GoogleFonts.concertOne(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by arrival city...',
                hintStyle: GoogleFonts.concertOne(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD13438)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD13438)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFD13438), width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredFlights.isEmpty
                ? Center(
                    child: Text(
                      'No flights found',
                      style: GoogleFonts.concertOne(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFlights.length,
                    itemBuilder: (context, index) {
                      final flight = filteredFlights[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: FlightCard(
                          flightData: flight,
                          isPast: flight['status'] == 'past',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
