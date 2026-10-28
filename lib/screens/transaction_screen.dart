import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key, required this.transaction});

  final MomoTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.isIn;
    final color = incoming ? const Color(0xFF157A45) : const Color(0xFFB4332A);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incoming ? 'IN' : 'OUT',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${incoming ? '+' : '−'}${rwf(transaction.amount)} RWF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  transaction.description,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Delete puts this line back only if Undo is tapped. If removing it would make an earlier balance negative, the wallet refuses.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
