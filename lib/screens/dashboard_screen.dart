import 'package:flutter/material.dart';

import '../models/mock_data.dart';
import 'login_screen.dart';
import 'report_screen.dart';
import 'scan_screen.dart';

/// Home screen after sign-in. It reads [currentUser] and [sampleScans].
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _logOut(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestGrade = sampleScans.isEmpty
        ? 'None'
        : sampleScans.first.generalGrade;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _logOut(context),
            child: const Text('Log Out'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Hello, ${currentUser.name}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text('${currentUser.role} in Cabadbaran City'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Scans',
                      value: '${sampleScans.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Latest Soil Grade',
                      value: latestGrade,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ScanScreen(),
                    ),
                  );
                },
                child: const Text('Start a new scan'),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent scans',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (sampleScans.isEmpty)
                const Text('No scans yet. Run a diagnostic to add one.')
              else
                for (final scan in sampleScans)
                  Card(
                    // Card groups one scan into a tappable block.
                    child: ListTile(
                      title: Text(scan.cropName),
                      subtitle: Text(
                        'pH ${scan.ph} · ${scan.generalGrade}\n${formatScanDate(scan.scannedAt)}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => ReportScreen(scan: scan),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small summary tile: a label on top and a value underneath.
class _StatCard extends StatelessWidget {
  const _StatCard({
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
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
