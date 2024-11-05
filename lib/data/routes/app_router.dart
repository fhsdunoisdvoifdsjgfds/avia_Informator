import 'package:flight_list/view/pages/add_flight/Add_Flight_Screen.dart';
import 'package:flight_list/view/pages/home/Home_Screen.dart';
import 'package:flight_list/view/pages/spalsh/Splash_Screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String addFlight = '/add-flight';

  static Map<String, Widget Function(BuildContext)> routes = {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    addFlight: (context) => const AddFlightScreen(),
  };
}
