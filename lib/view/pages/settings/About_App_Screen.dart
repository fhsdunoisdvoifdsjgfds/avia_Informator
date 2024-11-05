import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'About App',
          style: GoogleFonts.concertOne(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD13438)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Personal Flight Assistant',
              style: GoogleFonts.concertOne(
                color: const Color(0xFFD13438),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to the ultimate flight tracking experience! Our app is designed to make your journey management effortless and enjoyable.',
              style: GoogleFonts.concertOne(
                color: Colors.white,
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Key Features:',
              style: GoogleFonts.concertOne(
                color: const Color(0xFFD13438),
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeature('• Track upcoming and past flights'),
            _buildFeature('• Detailed flight information'),
            _buildFeature('• Easy flight management'),
            _buildFeature('• Smart search functionality'),
            _buildFeature('• Beautiful dark mode interface'),
            const Spacer(),
            Center(
              child: Text(
                'Version 1.0.1',
                style: GoogleFonts.concertOne(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: GoogleFonts.concertOne(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}
