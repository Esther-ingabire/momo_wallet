import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:momo_wallet/models/momo_transaction.dart';

// The signed-in user's transactions: users/{uid}/transactions
CollectionReference<Map<String, dynamic>> myTransactions() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('transactions');
}

Future<void> addTransaction(
  MomoTransaction transaction, {
  DateTime? createdAt,
}) async {
  await myTransactions().add({
    ...transaction.toMap(),
    'createdAt': createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt),
  });
}

Future<void> updateTransaction(MomoTransaction transaction) async {
  await myTransactions().doc(transaction.id).update(transaction.toMap());
}

Future<void> deleteTransactionDoc(String id) async {
  await myTransactions().doc(id).delete();
}

// Undo: write the same transaction back under the same id.
Future<void> restoreTransaction(MomoTransaction transaction) async {
  await myTransactions().doc(transaction.id).set({
    ...transaction.toMap(),
    'createdAt': transaction.createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(transaction.createdAt!),
  });
}

// Sample data, written once when a new account is created.
// Times are one second apart so newest-first has a stable order.
Future<void> addSampleTransactions() async {
  final now = DateTime.now();
  final samples = [
    MomoTransaction(description: 'Opening balance', amount: 10000, isIn: true),
    MomoTransaction(
      description: 'Sent to 0788123456',
      amount: 2500,
      isIn: false,
    ),
    MomoTransaction(
      description: 'Received from Keza',
      amount: 4000,
      isIn: true,
    ),
  ];
  final batch = FirebaseFirestore.instance.batch();
  for (var i = 0; i < samples.length; i++) {
    batch.set(myTransactions().doc(), {
      ...samples[i].toMap(),
      'createdAt': Timestamp.fromDate(now.add(Duration(seconds: i))),
    });
  }
  await batch.commit();
}
