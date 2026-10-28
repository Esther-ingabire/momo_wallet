import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/ui/show_message.dart';

class SendResult {
  SendResult({required this.sent, required this.fee});

  final MomoTransaction sent;
  final MomoTransaction fee;
}

class SendScreen extends StatefulWidget {
  const SendScreen({super.key, required this.balance});

  final int balance;

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final phoneController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void send() {
    final phone = phoneController.text.trim();
    final phoneError = phoneProblem(phone);
    if (phoneError != null) {
      showMessage(context, phoneError);
      return;
    }

    final amountError = sendAmountProblem(
      amountController.text,
      widget.balance,
    );
    if (amountError != null) {
      showMessage(context, amountError);
      return;
    }

    final amount = int.parse(amountController.text.trim());
    Navigator.pop(
      context,
      SendResult(
        sent: MomoTransaction(
          description: 'Sent to $phone',
          amount: amount,
          isIn: false,
        ),
        fee: MomoTransaction(
          description: 'Send fee',
          amount: sendFee,
          isIn: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Balance: ${rwf(widget.balance)} RWF'),
          const SizedBox(height: 8),
          const Text(
            'The number must be 10 digits and start with 078 or 079. The amount must be at least 100 RWF. A 100 RWF fee is added as its own OUT.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '0788123456',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: '1000',
              suffixText: 'RWF',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: send, child: const Text('Send money')),
        ],
      ),
    );
  }
}
