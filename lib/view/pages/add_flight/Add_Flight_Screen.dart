import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({Key? key}) : super(key: key);

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _depTerminalController = TextEditingController();
  final TextEditingController _arrTerminalController = TextEditingController();
  final TextEditingController _depDateController = TextEditingController();
  final TextEditingController _arrDateController = TextEditingController();
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _depTerminalController.dispose();
    _arrTerminalController.dispose();
    _depDateController.dispose();
    _arrDateController.dispose();
    _flightNumberController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveFlight() async {
    if (_formKey.currentState!.validate()) {
      final flight = {
        'departure': _departureController.text,
        'arrival': _arrivalController.text,
        'depTerminal': _depTerminalController.text,
        'arrTerminal': _arrTerminalController.text,
        'depDate': _depDateController.text,
        'arrDate': _arrDateController.text,
        'flightNumber': _flightNumberController.text,
        'price': _priceController.text,
        'duration': _durationController.text,
      };

      final prefs = await SharedPreferences.getInstance();
      List<String> flights = prefs.getStringList('flights') ?? [];
      flights.add(jsonEncode(flight));
      await prefs.setStringList('flights', flights);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Flight successfully added!',
              style: GoogleFonts.concertOne(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFD13438),
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.concertOne(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: GoogleFonts.concertOne(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[900],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFD13438), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFD13438), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Add Flight',
          style: GoogleFonts.concertOne(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD13438)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                label: 'DEPARTURE CITY',
                controller: _departureController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Field is required' : null,
              ),
              _buildTextField(
                label: 'ARRIVAL CITY',
                controller: _arrivalController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Field is required' : null,
              ),
              _buildTextField(
                label: 'DEPARTURE TERMINAL',
                controller: _depTerminalController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Field is required' : null,
              ),
              _buildTextField(
                label: 'ARRIVAL TERMINAL',
                controller: _arrTerminalController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Field is required' : null,
              ),
              _buildTextField(
                label: 'DEPARTURE DATE & TIME',
                controller: _depDateController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Field is required' : null,
              ),
              _buildTextField(
                label: 'ARRIVAL DATE & TIME',
                controller: _arrDateController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Field is required' : null,
              ),
              _buildTextField(
                label: 'FLIGHT NUMBER',
                controller: _flightNumberController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Field is required' : null,
              ),
              _buildTextField(
                label: 'DURATION (e.g., 2h/35m)',
                controller: _durationController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Field is required' : null,
              ),
              _buildTextField(
                label: 'PRICE (\$)',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Field is required';
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveFlight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD13438),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'ADD FLIGHT',
                  style: GoogleFonts.concertOne(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
