import 'dart:io';

import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/state/wallet_state.dart';
import 'package:momo_wallet/ui/receipt_photo.dart';
import 'package:momo_wallet/ui/show_message.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key, required this.transaction});

  final MomoTransaction transaction;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late final TextEditingController descriptionController;
  File? _photo;
  bool _saving = false;

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
    final wallet = context.read<WalletState>();
    setState(() => _saving = true);
    try {
      var photoUrl = widget.transaction.photoUrl;
      if (_photo != null) {
        photoUrl = await wallet.uploadPhoto(_photo!);
      }
      await wallet.edit(
        MomoTransaction(
          id: widget.transaction.id,
          description: description,
          amount: widget.transaction.amount,
          isIn: widget.transaction.isIn,
          createdAt: widget.transaction.createdAt,
          photoUrl: photoUrl,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, 'Could not save the photo. $e');
    }
  }

  Future<void> remove() async {
    final wallet = context.read<WalletState>();
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
    final problem = deleteProblem(wallet.transactions, widget.transaction);
    if (problem != null) {
      showMessage(context, problem);
      return;
    }
    await wallet.remove(widget.transaction);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<WalletState>().balance;
    final incoming = widget.transaction.isIn;
    final color = incoming ? const Color(0xFF157A45) : const Color(0xFFB4332A);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your balance: ${rwf(balance)} RWF',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
          ReceiptPhoto(
            photo: _photo,
            savedUrl: widget.transaction.photoUrl,
            busy: _saving,
            onPicked: (file) => setState(() => _photo = file),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : save,
            child: Text(_saving ? 'Saving...' : 'Save'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: remove, child: const Text('Delete')),
        ],
      ),
    );
  }
}
