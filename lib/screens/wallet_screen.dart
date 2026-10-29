import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momo_wallet/logic/wallet_cloud.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/screens/cash_out_screen.dart';
import 'package:momo_wallet/screens/receive_screen.dart';
import 'package:momo_wallet/screens/send_screen.dart';
import 'package:momo_wallet/screens/transaction_screen.dart';
import 'package:momo_wallet/ui/exchange_rate_card.dart';
import 'package:momo_wallet/ui/show_message.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  final String userId;
  final String email;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<MomoTransaction> transactions = [];
  String filter = 'All';
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _transactions;

  @override
  void initState() {
    super.initState();
    // Locked to this account. Logging in as someone else builds a new screen.
    _transactions = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> openReceive() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReceiveScreen()),
    );
    if (!mounted || result is! MomoTransaction) return;
    await addTransaction(result);
  }

  Future<void> openSend() async {
    final balance = statsFor(transactions).balance;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendScreen(balance: balance)),
    );
    if (!mounted || result is! SendResult) return;
    final now = DateTime.now();
    await addTransaction(result.sent, createdAt: now);
    await addTransaction(
      result.fee,
      createdAt: now.add(const Duration(milliseconds: 1)),
    );
  }

  Future<void> openCashOut() async {
    final balance = statsFor(transactions).balance;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CashOutScreen(balance: balance)),
    );
    if (!mounted || result is! MomoTransaction) return;
    await addTransaction(result);
  }

  void openDetails(MomoTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionScreen(
          transaction: transaction,
          transactions: transactions,
        ),
      ),
    );
  }

  Future<void> deleteTransaction(MomoTransaction transaction) async {
    final problem = deleteProblem(transactions, transaction);
    if (problem != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot delete'),
          content: const Text(
            'The balance would go below 0. Delete a newer payment first, or delete an outgoing one.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    if (transaction.id.isEmpty) return;

    try {
      await deleteTransactionDoc(transaction.id);
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Could not delete. $e');
      return;
    }
    if (!mounted) return;
    showMessage(
      context,
      '${transaction.description} deleted',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          restoreTransaction(transaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sawa Wallet'),
        leading: const Icon(Icons.account_balance_wallet_outlined),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _transactions,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load your transactions.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          transactions = snapshot.data!.docs
              .map(MomoTransaction.fromDoc)
              .toList();
          final stats = statsFor(transactions);
          final shown = visibleTransactions(transactions, filter);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF083D32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.email.isEmpty
                            ? 'Available balance'
                            : widget.email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Available balance',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${rwf(stats.balance)} RWF',
                        style: const TextStyle(
                          color: Color(0xFFF4C95D),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ExchangeRateCard(balanceRwf: stats.balance),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _StatBox(label: 'Total in', value: stats.totalIn),
                    const SizedBox(width: 8),
                    _StatBox(label: 'Total out', value: stats.totalOut),
                    const SizedBox(width: 8),
                    _StatBox(label: 'Lowest', value: stats.lowestBalance),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _ActionButton(
                      label: 'Receive',
                      icon: Icons.call_received,
                      onPressed: openReceive,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Send',
                      icon: Icons.send,
                      onPressed: openSend,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Cash out',
                      icon: Icons.payments,
                      onPressed: openCashOut,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    for (final label in ['All', 'IN', 'OUT']) ...[
                      ChoiceChip(
                        label: Text(label),
                        selected: filter == label,
                        onSelected: (_) {
                          setState(() {
                            filter = label;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Newest first. Tap a row to edit. Tap the bin to delete.',
                  ),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? Center(child: Text(_emptyText(filter)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: shown.length,
                        itemBuilder: (context, index) {
                          final transaction = shown[index];
                          return _TransactionTile(
                            transaction: transaction,
                            onTap: () => openDetails(transaction),
                            onDelete: () => deleteTransaction(transaction),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _emptyText(String filter) {
  if (filter == 'IN') return 'No money in yet';
  if (filter == 'OUT') return 'No money out yet';
  return 'No transactions yet';
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              rwf(value),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  final MomoTransaction transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.isIn;
    final color = incoming ? const Color(0xFF157A45) : const Color(0xFFB4332A);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: incoming
            ? const Color(0xFFD9F2E4)
            : const Color(0xFFF8D9D6),
        child: Icon(
          incoming ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(
        incoming ? 'IN' : 'OUT',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${incoming ? '+' : '−'}${rwf(transaction.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          IconButton(
            tooltip: 'Delete',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Color(0xFFB4332A)),
          ),
        ],
      ),
      onTap: onTap,
      onLongPress: onDelete,
    );
  }
}
