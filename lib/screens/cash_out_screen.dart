import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/ui/show_message.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key, required this.balance});

  final int balance;

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final amountController = TextEditingController();
  List<NoteLine> notes = [];
  int? preparedAmount;

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

  void confirm() {
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

    final balanceProblem = cashOutBalanceProblem(amount, widget.balance);
    if (balanceProblem != null) {
      showMessage(context, balanceProblem);
      return;
    }

    Navigator.pop(
      context,
      MomoTransaction(description: 'Cash out', amount: amount, isIn: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final short = preparedAmount != null && preparedAmount! > widget.balance;

    return Scaffold(
      appBar: AppBar(title: const Text('Cash out')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Balance: ${rwf(widget.balance)} RWF'),
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
          FilledButton(
            onPressed: confirm,
            child: const Text('Confirm cash out'),
          ),
        ],
      ),
    );
  }
}
