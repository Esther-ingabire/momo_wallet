import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRate {
  ExchangeRate({required this.rwfPerUsd, required this.updated});

  // How many RWF one US dollar buys today.
  final double rwfPerUsd;
  final String updated;

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    final rates = json['rates'] as Map<String, dynamic>;
    return ExchangeRate(
      rwfPerUsd: (rates['RWF'] as num).toDouble(),
      updated: json['time_last_update_utc'] as String,
    );
  }
}

Future<ExchangeRate> fetchUsdRate() async {
  final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception('The rate server answered ${response.statusCode}');
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (data['result'] != 'success') {
    throw Exception('The rate server did not return a rate');
  }
  return ExchangeRate.fromJson(data);
}

/// "Wed, 28 Oct 2026 00:02:31 +0000" becomes "28 Oct 2026".
String rateDay(String updated) {
  final parts = updated.split(' ');
  if (parts.length >= 4) return '${parts[1]} ${parts[2]} ${parts[3]}';
  return updated;
}
