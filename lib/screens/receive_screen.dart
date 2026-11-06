import 'dart:io';

import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/state/wallet_state.dart';
import 'package:momo_wallet/ui/receipt_photo.dart';
import 'package:momo_wallet/ui/show_message.dart';
import 'package:provider/provider.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  File? _photo;
  bool _saving = false;

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> addMoney() async {
    final problem = receiveProblem(
      descriptionController.text,
      amountController.text,
    );
    if (problem != null) {
      showMessage(context, problem);
      return;
    }

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
        MomoTransaction(
          description: descriptionController.text.trim(),
          amount: int.parse(amountController.text.trim()),
          isIn: true,
          photoUrl: photoUrl,
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
      appBar: AppBar(title: const Text('Receive money')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your balance: ${rwf(balance)} RWF',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          ReceiptPhoto(
            photo: _photo,
            busy: _saving,
            onPicked: (file) => setState(() => _photo = file),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : addMoney,
            child: Text(_saving ? 'Saving...' : 'Add money'),
          ),
        ],
      ),
    );
  }
}
