import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  final String starter;

  GameScreen({
    required this.starter,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.starter),
          ),
        ),
      ),
    );
  }
}

class FlightCard extends StatelessWidget {
  final Map<String, dynamic> flightData;
  final Function? onStatusChanged;
  final bool isPast;

  const FlightCard({
    Key? key,
    required this.flightData,
    this.onStatusChanged,
    this.isPast = false,
  }) : super(key: key);

  Future<void> _showConfirmationDialog(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          'Move to Past Flights?',
          style: GoogleFonts.concertOne(),
        ),
        content: Text(
          'Do you want to move this flight to past flights?',
          style: GoogleFonts.concertOne(),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.concertOne(),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _moveToPastFlights(context);
            },
            child: Text(
              'Move',
              style: GoogleFonts.concertOne(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToPastFlights(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> upcomingFlights = prefs.getStringList('flights') ?? [];
    List<String> pastFlights = prefs.getStringList('past_flights') ?? [];
    upcomingFlights.removeWhere((flight) {
      final Map<String, dynamic> flightMap = json.decode(flight);
      return flightMap['flightNumber'] == flightData['flightNumber'];
    });
    pastFlights.add(json.encode(flightData));
    await prefs.setStringList('flights', upcomingFlights);
    await prefs.setStringList('past_flights', pastFlights);

    if (onStatusChanged != null) {
      onStatusChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast ? Colors.grey : const Color(0xFFD13438),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isPast ? Colors.grey : const Color(0xFFD13438),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                if (!isPast)
                  GestureDetector(
                    onTap: () => _showConfirmationDialog(context),
                    child: const Icon(Icons.check_circle_outline,
                        color: Colors.white),
                  )
                else
                  const Icon(Icons.history, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isPast ? 'past flight' : 'planned flight',
                  style: GoogleFonts.concertOne(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      flightData['departure']
                          .toString()
                          .substring(0, 3)
                          .toUpperCase(),
                      style: GoogleFonts.concertOne(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.flight, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          flightData['duration'],
                          style: GoogleFonts.concertOne(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      flightData['arrival']
                          .toString()
                          .substring(0, 3)
                          .toUpperCase(),
                      style: GoogleFonts.concertOne(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flightData['departure'],
                          style: GoogleFonts.concertOne(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          flightData['depTerminal'],
                          style: GoogleFonts.concertOne(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flightData['arrival'],
                          style: GoogleFonts.concertOne(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          flightData['arrTerminal'],
                          style: GoogleFonts.concertOne(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DATE & TIME',
                          style: GoogleFonts.concertOne(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          flightData['depDate'],
                          style: GoogleFonts.concertOne(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'DATE & TIME',
                          style: GoogleFonts.concertOne(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          flightData['arrDate'],
                          style: GoogleFonts.concertOne(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FLIGHT NUMBER',
                          style: GoogleFonts.concertOne(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          flightData['flightNumber'],
                          style: GoogleFonts.concertOne(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.airline_seat_recline_normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL PRICE:',
                      style: GoogleFonts.concertOne(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '\$${flightData['price']}',
                      style: GoogleFonts.concertOne(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
