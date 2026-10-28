import 'dart:convert';

import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'transactions';

Future<void> saveTransactions(List<MomoTransaction> items) async {
  // Turn the list into text before any await, so a later edit cannot sneak in.
  final text = jsonEncode(items.map((item) => item.toJson()).toList());
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, text);
}

/// Null the very first time, before anything has been saved.
Future<List<MomoTransaction>?> loadTransactions() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_key);
  if (saved == null) return null;
  final list = jsonDecode(saved) as List;
  return list
      .map((x) => MomoTransaction.fromJson(x as Map<String, dynamic>))
      .toList();
}
