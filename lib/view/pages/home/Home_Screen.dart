import 'package:flight_list/view/widgets/drawer_menu.dart';
import 'package:flight_list/view/widgets/flight_card.dart';
import 'package:flight_list/view/widgets/home_switcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isUpcoming = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> upcomingFlights = [];
  List<Map<String, dynamic>> pastFlights = [];

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    final prefs = await SharedPreferences.getInstance();
    final upcomingList = prefs.getStringList('flights') ?? [];
    final pastList = prefs.getStringList('past_flights') ?? [];

    setState(() {
      upcomingFlights = upcomingList
          .map((flight) => Map<String, dynamic>.from(jsonDecode(flight)))
          .toList();
      pastFlights = pastList
          .map((flight) => Map<String, dynamic>.from(jsonDecode(flight)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentFlights = isUpcoming ? upcomingFlights : pastFlights;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: const DrawerMenu(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD13438),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Your flights info',
                    style: GoogleFonts.concertOne(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomSwitch(
                value: isUpcoming,
                onToggle: (value) {
                  setState(() {
                    isUpcoming = value;
                  });
                },
              ),
            ),
            Expanded(
              child: currentFlights.isEmpty
                  ? Center(
                      child: Text(
                        'No ${isUpcoming ? 'upcoming' : 'past'} flights',
                        style: GoogleFonts.concertOne(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: currentFlights.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: FlightCard(
                            flightData: currentFlights[index],
                            isPast: !isUpcoming,
                            onStatusChanged: _loadFlights,
                          ),
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
