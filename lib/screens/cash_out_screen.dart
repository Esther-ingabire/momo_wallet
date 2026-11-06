import 'dart:io';

import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/state/wallet_state.dart';
import 'package:momo_wallet/ui/receipt_photo.dart';
import 'package:momo_wallet/ui/show_message.dart';
import 'package:provider/provider.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final amountController = TextEditingController();
  List<NoteLine> notes = [];
  int? preparedAmount;
  File? _photo;
  bool _saving = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void showNotes() {
    final problem = cashOutAmountProblem(amountController.text);
    if (problem != null) {
      setState(() {
        notes = [];
        preparedAmount = null;
      });
      showMessage(context, problem);
      return;
    }

    final amount = int.parse(amountController.text.trim());
    final lines = notesFor(amount);
    if (lines == null) {
      showMessage(context, 'Amount must be a multiple of 100');
      return;
    }

    setState(() {
      preparedAmount = amount;
      notes = lines;
    });
  }

  Future<void> confirm() async {
    final problem = cashOutAmountProblem(amountController.text);
    if (problem != null) {
      showMessage(context, problem);
      return;
    }

    final amount = int.parse(amountController.text.trim());
    if (preparedAmount != amount || notes.isEmpty) {
      showMessage(context, 'Show the notes before you confirm');
      return;
    }

    final balanceProblem = cashOutBalanceProblem(
      amount,
      context.read<WalletState>().balance,
    );
    if (balanceProblem != null) {
      showMessage(context, balanceProblem);
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
          description: 'Cash out',
          amount: amount,
          isIn: false,
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
    final short = preparedAmount != null && preparedAmount! > balance;

    return Scaffold(
      appBar: AppBar(title: const Text('Cash out')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your balance: ${rwf(balance)} RWF',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'The agent has 5,000, 2,000, 1,000, 500 and 100 RWF notes. The amount must be a multiple of 100.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (preparedAmount == null) return;
              final typed = int.tryParse(amountController.text.trim());
              if (typed == preparedAmount) return;
              setState(() {
                preparedAmount = null;
                notes = [];
              });
            },
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: '2000',
              suffixText: 'RWF',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: showNotes, child: const Text('Show notes')),
          const SizedBox(height: 16),
          if (notes.isEmpty)
            const Text('The notes appear here before you confirm.')
          else ...[
            Text(
              notesText(notes),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (short) ...[
              const SizedBox(height: 8),
              const Text(
                'This is more than your balance. Confirm will be refused.',
                style: TextStyle(color: Color(0xFFB4332A)),
              ),
            ],
            const SizedBox(height: 8),
            for (final line in notes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_outlined),
                title: Text('${rwf(line.value)} RWF'),
                trailing: Text('× ${line.count}'),
              ),
          ],
          const SizedBox(height: 8),
          ReceiptPhoto(
            photo: _photo,
            busy: _saving,
            onPicked: (file) => setState(() => _photo = file),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saving ? null : confirm,
            child: Text(_saving ? 'Saving...' : 'Confirm cash out'),
          ),
        ],
      ),
    );
  }
}
