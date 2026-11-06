import 'dart:io';

import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/state/wallet_state.dart';
import 'package:momo_wallet/ui/receipt_photo.dart';
import 'package:momo_wallet/ui/show_message.dart';
import 'package:provider/provider.dart';

class SendResult {
  SendResult({required this.sent, required this.fee});

  final MomoTransaction sent;
  final MomoTransaction fee;
}

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  File? _photo;
  bool _saving = false;

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final phone = phoneController.text.trim();
    final phoneError = phoneProblem(phone);
    if (phoneError != null) {
      showMessage(context, phoneError);
      return;
    }

    final amountError = sendAmountProblem(
      amountController.text,
      context.read<WalletState>().balance,
    );
    if (amountError != null) {
      showMessage(context, amountError);
      return;
    }

    final amount = int.parse(amountController.text.trim());
    final wallet = context.read<WalletState>();
    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_photo != null) {
        photoUrl = await wallet.uploadPhoto(_photo!);
      }
      if (!mounted) return;
      Navigator.pop(
        context,
        SendResult(
          sent: MomoTransaction(
            description: 'Sent to $phone',
            amount: amount,
            isIn: false,
            photoUrl: photoUrl,
          ),
          fee: MomoTransaction(
            description: 'Send fee',
            amount: sendFee,
            isIn: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, 'Could not save the photo. $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<WalletState>().balance;
    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your balance: ${rwf(balance)} RWF',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
          const SizedBox(height: 16),
          ReceiptPhoto(
            photo: _photo,
            busy: _saving,
            onPicked: (file) => setState(() => _photo = file),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : send,
            child: Text(_saving ? 'Saving...' : 'Send money'),
          ),
        ],
      ),
    );
  }
}
