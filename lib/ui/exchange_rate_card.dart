import 'package:flutter/material.dart';
import 'package:momo_wallet/exchange_rate.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';

class ExchangeRateCard extends StatefulWidget {
  const ExchangeRateCard({super.key, required this.balanceRwf});

  final int balanceRwf;

  @override
  State<ExchangeRateCard> createState() => _ExchangeRateCardState();
}

class _ExchangeRateCardState extends State<ExchangeRateCard> {
  ExchangeRate? rate;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await fetchUsdRate();
      if (!mounted) return;
      setState(() {
        rate = result;
        loading = false;
        error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error =
            'Could not load the exchange rate. Check your internet connection.';
      });
    }
  }

  void retry() {
    setState(() {
      loading = true;
      error = null;
    });
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: loading
          ? const Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text("Loading today's dollar rate..."),
              ],
            )
          : error != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wifi_off),
                    SizedBox(width: 8),
                    Expanded(child: Text('Dollar rate')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(error!),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: retry,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's dollar rate",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('1 USD = ${rwf(rate!.rwfPerUsd.round())} RWF'),
                const SizedBox(height: 2),
                Text(
                  'Your balance is about ${_dollars(widget.balanceRwf, rate!.rwfPerUsd)} USD',
                ),
                const SizedBox(height: 2),
                Text(
                  'Updated ${rateDay(rate!.updated)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
    );
  }
}

String _dollars(int balanceRwf, double rwfPerUsd) {
  if (rwfPerUsd <= 0) return '0.00';
  return (balanceRwf / rwfPerUsd).toStringAsFixed(2);
}
