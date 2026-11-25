// In-memory stand-ins for the logged-in person and their soil scans.
//
// Nothing here talks to a server. The scan screen adds new readings to
// sampleScans, and the dashboard reads that same list.

/// Someone using SoilDex. [role] is either "Farmer" or "Agronomist".
class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;
}

/// One soil reading, either a sample or a scan the user just ran.
///
/// [ph] is acidity (7 is neutral). [ec] is electrical conductivity in dS/m,
/// which we use as a simple measure of salts in the soil.
class SoilScan {
  const SoilScan({
    required this.cropName,
    required this.ph,
    required this.ec,
    required this.moisture,
    required this.temperature,
    required this.visualSoilClass,
    required this.generalGrade,
    required this.cropRelativeGrade,
    required this.remediationTip,
    required this.scannedAt,
  });

  final String cropName;
  final double ph;
  final double ec;
  final double moisture;
  final double temperature;

  /// Texture guessed from a photo, such as Loam or Clay.
  final String visualSoilClass;

  /// How healthy the soil looks on its own, ignoring the crop.
  final String generalGrade;

  /// How well this soil fits the chosen crop.
  final String cropRelativeGrade;

  /// Short plain-language advice for the farmer.
  final String remediationTip;

  final DateTime scannedAt;
}

/// Choices shown in the register screen dropdown.
const List<String> userRoles = <String>['Farmer', 'Agronomist'];

/// Choices shown in the scan screen dropdown.
const List<String> targetCrops = <String>['Paddy Rice', 'Cacao', 'Banana'];

/// The person we treat as logged in. Register overwrites this.
AppUser currentUser = const AppUser(
  name: 'Maria Santos',
  email: 'maria.santos@cabadbaran.ph',
  role: 'Farmer',
);

/// Newest scans first. Starts with three examples for Cabadbaran City.
final List<SoilScan> sampleScans = <SoilScan>[
  diagnoseScan(
    cropName: 'Paddy Rice',
    ph: 5.8,
    ec: 0.6,
    moisture: 48,
    temperature: 28,
    photoCaptured: true,
    scannedAt: DateTime(2026, 11, 24),
  ),
  diagnoseScan(
    cropName: 'Cacao',
    ph: 5.2,
    ec: 0.8,
    moisture: 70,
    temperature: 33,
    photoCaptured: true,
    scannedAt: DateTime(2026, 11, 18),
  ),
  diagnoseScan(
    cropName: 'Banana',
    ph: 6.4,
    ec: 2.4,
    moisture: 22,
    temperature: 29,
    photoCaptured: true,
    scannedAt: DateTime(2026, 11, 9),
  ),
];

/// Saves a scan in memory so the dashboard can show it. Nothing is written to disk.
void saveScan(SoilScan scan) {
  sampleScans.insert(0, scan);
}

/// Builds grades and a tip from the numbers typed on the scan screen.
///
/// These rules are a teaching placeholder. A later version can swap in a
/// real soil model without changing the screens.
SoilScan diagnoseScan({
  required String cropName,
  required double ph,
  required double ec,
  required double moisture,
  required double temperature,
  required bool photoCaptured,
  DateTime? scannedAt,
}) {
  return SoilScan(
    cropName: cropName,
    ph: ph,
    ec: ec,
    moisture: moisture,
    temperature: temperature,
    visualSoilClass: _visualSoilClass(
      photoCaptured: photoCaptured,
      moisture: moisture,
    ),
    generalGrade: _generalGrade(
      ph: ph,
      ec: ec,
      moisture: moisture,
      temperature: temperature,
    ),
    cropRelativeGrade: _cropRelativeGrade(
      cropName: cropName,
      ph: ph,
      ec: ec,
      moisture: moisture,
    ),
    remediationTip: _remediationTip(
      cropName: cropName,
      ph: ph,
      ec: ec,
      moisture: moisture,
    ),
    scannedAt: scannedAt ?? DateTime.now(),
  );
}

/// Turns a date into text like "24 Nov 2026" without an extra package.
String formatScanDate(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// Pretends a photo was classified. Wetter soil is treated as a finer texture.
String _visualSoilClass({
  required bool photoCaptured,
  required double moisture,
}) {
  if (!photoCaptured) {
    return 'Not captured';
  }
  if (moisture >= 55) {
    return 'Clay';
  }
  if (moisture >= 35) {
    return 'Loam';
  }
  return 'Sandy Loam';
}

/// Scores pH, salts, moisture, and temperature, then picks a word grade.
String _generalGrade({
  required double ph,
  required double ec,
  required double moisture,
  required double temperature,
}) {
  var points = 0;

  if (ph >= 6.0 && ph <= 7.0) {
    points += 2;
  } else if (ph >= 5.5 && ph <= 7.5) {
    points += 1;
  }

  if (ec >= 0.2 && ec <= 1.2) {
    points += 2;
  } else if (ec <= 2.0) {
    points += 1;
  }

  if (moisture >= 25 && moisture <= 60) {
    points += 2;
  } else if (moisture >= 15 && moisture <= 80) {
    points += 1;
  }

  if (temperature >= 24 && temperature <= 32) {
    points += 2;
  } else if (temperature >= 18 && temperature <= 36) {
    points += 1;
  }

  if (points >= 7) {
    return 'Excellent';
  }
  if (points >= 5) {
    return 'Good';
  }
  if (points >= 3) {
    return 'Fair';
  }
  return 'Poor';
}

/// Compares the reading with a rough comfort range for the chosen crop.
String _cropRelativeGrade({
  required String cropName,
  required double ph,
  required double ec,
  required double moisture,
}) {
  final bool phOk;
  final bool moistureOk;

  if (cropName == 'Paddy Rice') {
    phOk = ph >= 5.5 && ph <= 6.5;
    moistureOk = moisture >= 40 && moisture <= 80;
  } else if (cropName == 'Cacao') {
    phOk = ph >= 6.0 && ph <= 7.0;
    moistureOk = moisture >= 25 && moisture <= 55;
  } else if (cropName == 'Banana') {
    phOk = ph >= 5.5 && ph <= 7.0;
    moistureOk = moisture >= 30 && moisture <= 60;
  } else {
    phOk = ph >= 5.5 && ph <= 7.0;
    moistureOk = moisture >= 20 && moisture <= 70;
  }

  final saltOk = ec >= 0.1 && ec <= 1.5;
  final matches = (phOk ? 1 : 0) + (moistureOk ? 1 : 0) + (saltOk ? 1 : 0);

  if (matches == 3) {
    return 'Highly Suitable';
  }
  if (matches == 2) {
    return 'Suitable';
  }
  if (matches == 1) {
    return 'Marginal';
  }
  return 'Not Suitable';
}

/// Picks one piece of advice from the reading that most needs attention.
String _remediationTip({
  required String cropName,
  required double ph,
  required double ec,
  required double moisture,
}) {
  if (ph < 5.5) {
    return 'Soil is acidic for $cropName. Apply agricultural lime, then scan again in about four weeks.';
  }
  if (ph > 7.5) {
    return 'Soil is alkaline for $cropName. Mix in compost and scan again before planting.';
  }
  if (ec > 2.0) {
    return 'Salts are high for $cropName. Flush the field with clean water and improve drainage.';
  }
  if (moisture < 20) {
    return 'Soil is dry for $cropName. Irrigate, then cover the soil with mulch.';
  }
  if (moisture > 80 && cropName != 'Paddy Rice') {
    return 'Soil is very wet for $cropName. Improve drainage so roots are not sitting in water.';
  }
  return 'Readings look workable for $cropName. Keep mulch in place and scan again next month.';
}
