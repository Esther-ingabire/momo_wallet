import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/ui/show_message.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void addMoney() {
    final problem = receiveProblem(
      descriptionController.text,
      amountController.text,
    );
    if (problem != null) {
      showMessage(context, problem);
      return;
    }

    Navigator.pop(
      context,
      MomoTransaction(
        description: descriptionController.text.trim(),
        amount: int.parse(amountController.text.trim()),
        isIn: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive money')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Money that arrives is an IN. The amount has to be a whole number above 0.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Received from Eric',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: '5000',
              suffixText: 'RWF',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: addMoney, child: const Text('Add money')),
        ],
      ),
    );
  }
}
