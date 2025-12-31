import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../logic/auth_provider.dart';
import 'package:tamakochi_app/l10n/app_localizations.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state to handle errors or loading
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background - later we can add a nice image or gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  AppLocalizations.of(context)?.welcomeMessage ?? 'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Login Button
                if (authState.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).signInWithGoogle();
                    },
                    icon: const Icon(Icons.login),
                    label: Text(AppLocalizations.of(context)?.signInWithGoogle ?? 'Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                if (authState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Error: ${authState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
