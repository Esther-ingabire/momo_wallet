import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_cloud.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/ui/show_message.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({
    super.key,
    required this.transaction,
    required this.transactions,
  });

  final MomoTransaction transaction;
  final List<MomoTransaction> transactions;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(
      text: widget.transaction.description,
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      showMessage(context, 'Description cannot be empty');
      return;
    }
    await updateTransaction(
      MomoTransaction(
        id: widget.transaction.id,
        description: description,
        amount: widget.transaction.amount,
        isIn: widget.transaction.isIn,
        createdAt: widget.transaction.createdAt,
      ),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> remove() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this transaction?'),
        content: Text(widget.transaction.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    final problem = deleteProblem(widget.transactions, widget.transaction);
    if (problem != null) {
      showMessage(context, problem);
      return;
    }
    await deleteTransactionDoc(widget.transaction.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final incoming = widget.transaction.isIn;
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
                  '${incoming ? '+' : '−'}${rwf(widget.transaction.amount)} RWF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: save, child: const Text('Save')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: remove, child: const Text('Delete')),
        ],
      ),
    );
  }
}
