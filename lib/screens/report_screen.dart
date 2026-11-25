import 'package:flutter/material.dart';

import '../models/mock_data.dart';
import 'dashboard_screen.dart';

/// Shows one finished scan: numbers, grades, texture, and advice.
class ReportScreen extends StatelessWidget {
  const ReportScreen({
    super.key,
    required this.scan,
  });

  /// The reading this page was opened with.
  final SoilScan scan;

  void _backToDashboard(BuildContext context) {
    // A fresh dashboard reads the in-memory list, including any new scan.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const DashboardScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Report'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                scan.cropName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(formatScanDate(scan.scannedAt)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _MetricRow(label: 'Soil pH', value: '${scan.ph}'),
                      _MetricRow(label: 'EC', value: '${scan.ec} dS/m'),
                      _MetricRow(
                        label: 'Moisture',
                        value: '${scan.moisture}%',
                      ),
                      _MetricRow(
                        label: 'Temperature',
                        value: '${scan.temperature} °C',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GradeCard(
                      label: 'General Grade',
                      value: scan.generalGrade,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradeCard(
                      label: 'Crop-Relative Grade',
                      value: scan.cropRelativeGrade,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Visual soil texture'),
                  subtitle: Text(scan.visualSoilClass),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Remediation advice'),
                  subtitle: Text(scan.remediationTip),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _backToDashboard(context),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One label on the left and its reading on the right.
class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

/// A card used for General Grade and Crop-Relative Grade.
class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
