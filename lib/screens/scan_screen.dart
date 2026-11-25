import 'package:flutter/material.dart';

import '../models/mock_data.dart';
import 'report_screen.dart';

/// Form that pretends to read a soil probe and a soil photo.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phController = TextEditingController();
  final TextEditingController _ecController = TextEditingController();
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();

  // Null until the user picks a crop from the dropdown.
  String? _crop;

  // These switches stand in for a real Bluetooth probe and camera.
  bool _probeConnected = false;
  bool _photoCaptured = false;

  @override
  void dispose() {
    _phController.dispose();
    _ecController.dispose();
    _moistureController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  void _runScan() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_probeConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turn on BLE Probe Connected before running a scan.'),
        ),
      );
      return;
    }

    final crop = _crop;
    if (crop == null) {
      return;
    }

    final scan = diagnoseScan(
      cropName: crop,
      ph: double.parse(_phController.text.trim()),
      ec: double.parse(_ecController.text.trim()),
      moisture: double.parse(_moistureController.text.trim()),
      temperature: double.parse(_temperatureController.text.trim()),
      photoCaptured: _photoCaptured,
    );
    saveScan(scan);

    // Clear the stack so the dashboard built afterwards includes this scan.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ReportScreen(scan: scan),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Scan'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Type the probe readings, then run a practice diagnostic. The switches are simulated.',
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _crop,
                  decoration: const InputDecoration(
                    labelText: 'Target Crop',
                  ),
                  items: [
                    for (final crop in targetCrops)
                      DropdownMenuItem<String>(
                        value: crop,
                        child: Text(crop),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => _crop = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Choose a target crop.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Soil pH',
                  ),
                  validator: (value) => _numberInRange(
                    value,
                    label: 'Soil pH',
                    min: 0,
                    max: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ecController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'EC (dS/m)',
                  ),
                  validator: (value) => _numberInRange(
                    value,
                    label: 'EC',
                    min: 0,
                    max: 20,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _moistureController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Moisture (%)',
                  ),
                  validator: (value) => _numberInRange(
                    value,
                    label: 'Moisture',
                    min: 0,
                    max: 100,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _temperatureController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Temperature (°C)',
                  ),
                  validator: (value) => _numberInRange(
                    value,
                    label: 'Temperature',
                    min: -10,
                    max: 60,
                  ),
                ),
                const SizedBox(height: 8),
                // SwitchListTile is a label plus an on/off switch.
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('BLE Probe Connected'),
                  subtitle: const Text('Simulated. No Bluetooth radio is used.'),
                  value: _probeConnected,
                  onChanged: (value) {
                    setState(() => _probeConnected = value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Soil Photo Captured'),
                  subtitle: const Text(
                    'Simulated. Texture is guessed from moisture when this is on.',
                  ),
                  value: _photoCaptured,
                  onChanged: (value) {
                    setState(() => _photoCaptured = value);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _runScan,
                  child: const Text('Run Diagnostic Scan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Checks that [value] is a number inside [min] and [max].
String? _numberInRange(
  String? value, {
  required String label,
  required double min,
  required double max,
}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'Enter $label.';
  }
  final parsed = double.tryParse(text);
  if (parsed == null) {
    return '$label must be a number.';
  }
  if (parsed < min || parsed > max) {
    return '$label must be between $min and $max.';
  }
  return null;
}
