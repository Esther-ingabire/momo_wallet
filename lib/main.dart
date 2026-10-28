import 'package:flutter/material.dart';
import 'package:momo_wallet/screens/wallet_screen.dart';

void main() {
  runApp(const SawaApp());
}

class SawaApp extends StatelessWidget {
  const SawaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0B6B4C);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sawa Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF3F6F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const WalletScreen(),
    );
  }
}
