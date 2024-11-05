import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isHomeScreen = ModalRoute.of(context)?.settings.name == '/home';

    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            if (!isHomeScreen)
              ListTile(
                leading: const Icon(Icons.flight, color: Color(0xFFD13438)),
                title: Text(
                  'My Flights',
                  style: GoogleFonts.concertOne(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Color(0xFFD13438)),
              title: Text(
                'Add Flight',
                style: GoogleFonts.concertOne(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-flight');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Color(0xFFD13438)),
              title: Text(
                'Search Flights',
                style: GoogleFonts.concertOne(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/search-flights');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFFD13438)),
              title: Text(
                'Statistics',
                style: GoogleFonts.concertOne(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/stats');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFFD13438)),
              title: Text(
                'Settings',
                style: GoogleFonts.concertOne(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
