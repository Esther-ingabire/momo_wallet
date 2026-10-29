import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:momo_wallet/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const AuthGate(),
    );
  }
}
