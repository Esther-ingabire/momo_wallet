import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momo_wallet/repositories/photo_repository.dart';
import 'package:momo_wallet/repositories/transaction_repository.dart';
import 'package:momo_wallet/screens/login_screen.dart';
import 'package:momo_wallet/screens/wallet_screen.dart';
import 'package:momo_wallet/state/wallet_state.dart';
import 'package:provider/provider.dart';

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
        // One brain for this user. It is thrown away when they log out.
        return ChangeNotifierProvider<WalletState>(
          create: (_) => WalletState(
            TransactionRepository(user.uid),
            PhotoRepository(),
          ),
          child: WalletScreen(email: user.email ?? ''),
        );
      },
    );
  }
}
