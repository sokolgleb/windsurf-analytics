import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authSignIn)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: () => _signIn(context, OAuthProvider.google),
                icon: const Icon(Icons.login),
                label: Text(l10n.authSignInWith('Google')),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _signIn(context, OAuthProvider.github),
                icon: const Icon(Icons.code),
                label: Text(l10n.authSignInWith('GitHub')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn(BuildContext context, OAuthProvider provider) async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(provider);
      if (context.mounted) context.go('/');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    }
  }
}
