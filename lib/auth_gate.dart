import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momo_wallet/login_screen.dart';
import 'package:momo_wallet/screens/wallet_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        // A new key drops the previous account's list when you log in
        // as somebody else.
        return WalletScreen(
          key: ValueKey(user.uid),
          userId: user.uid,
          email: user.email ?? '',
        );
      },
    );
  }
}
