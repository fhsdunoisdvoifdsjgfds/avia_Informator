import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _shareApp() {
    Share.share(
      'Track your flights with our amazing app! Download now from the App Store: ',
      subject: 'Check out this Flight Tracking App!',
    );
  }

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD13438)),
      title: Text(
        title,
        style: GoogleFonts.concertOne(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Settings',
          style: GoogleFonts.concertOne(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD13438)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () => Navigator.pushNamed(context, '/privacy', arguments: {
              'url': 'https://ringgoal.xyz/aviainformator-policy',
              'title': 'Privacy Policy'
            }),
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: 'Terms & Conditions',
            onTap: () => Navigator.pushNamed(context, '/privacy', arguments: {
              'url': 'https://ringgoal.xyz/aviainformator-terms',
              'title': 'Terms & Conditions'
            }),
          ),
          _buildSettingsTile(
            icon: Icons.share,
            title: 'Share App',
            onTap: _shareApp,
          ),
          _buildSettingsTile(
            icon: Icons.star,
            title: 'Rate App',
            onTap: _rateApp,
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About App',
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
    );
  }
}
