import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

/// Starts SoilDex.
void main() {
  runApp(const SoilDexApp());
}

/// The root widget. It paints the app with a green Material 3 theme
/// and shows [LoginScreen] first.
class SoilDexApp extends StatelessWidget {
  const SoilDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoilDex',
      // ColorScheme.fromSeed builds the rest of the palette from one green.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
