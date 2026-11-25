import 'package:flutter/material.dart';

import '../models/mock_data.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

/// Email and password form. Any non-empty pair is accepted for now.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Connects the Form to validate() when Log In is pressed.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Holds the text currently typed into each box.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Controllers must be disposed so they do not keep listening after this
    // screen is gone.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logIn() {
    // validate() runs every field's validator and returns false if one fails.
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Remember the email on the dummy user. The name and role stay as they are
    // until someone registers.
    currentUser = AppUser(
      name: currentUser.name,
      email: _emailController.text.trim(),
      role: currentUser.role,
    );

    // pushAndRemoveUntil drops the login screen so the back button cannot
    // reopen it after a successful sign-in.
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
      // Scaffold is the page: it gives us an app bar and a body.
      appBar: AppBar(
        title: const Text('SoilDex'),
      ),
      body: Center(
        // The max width keeps the form readable on a desktop browser.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Soil diagnostic for Cabadbaran City',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in with any email and password. This starter app does not check an account yet.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  onFieldSubmitted: (_) => _logIn(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _logIn,
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
