import 'package:flight_list/view/pages/add_flight/Add_Flight_Screen.dart';
import 'package:flight_list/view/pages/home/Home_Screen.dart';
import 'package:flight_list/view/pages/search/Search_Flight_Screen.dart';
import 'package:flight_list/view/pages/settings/About_App_Screen.dart';
import 'package:flight_list/view/pages/settings/Policy_Page_Settings.dart';
import 'package:flight_list/view/pages/settings/Settings_Screen.dart';
import 'package:flight_list/view/pages/spalsh/Splash_Screen.dart';
import 'package:flutter/material.dart';
import 'view/pages/stats/Stats_Flights_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFFD13438),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder(
              future: Future.delayed(const Duration(seconds: 3)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                return const HomeScreen();
              },
            ),
        '/home': (context) => const HomeScreen(),
        '/add-flight': (context) => const AddFlightScreen(),
        '/search-flights': (context) => const SearchFlightsScreen(),
        '/privacy': (context) => const PrivacyReadScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/stats': (context) => const StatsScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
