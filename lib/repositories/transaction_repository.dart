import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:momo_wallet/models/momo_transaction.dart';

// The only class that talks to Firestore.
// One repository belongs to one signed-in user.
class TransactionRepository {
  TransactionRepository(this.uid);

  final String uid;

  // users/{uid}/transactions: the path the security rules protect.
  CollectionReference<Map<String, dynamic>> get _transactions =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions');

  // The live pipe: the list now, and again after every change.
  Stream<List<MomoTransaction>> watchAll() => _transactions
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final list = <MomoTransaction>[];
        for (final doc in snapshot.docs) {
          try {
            list.add(MomoTransaction.fromDoc(doc));
          } catch (_) {
            // One badly typed document must not hide the rest of the list.
          }
        }
        return list;
      });

  Future<void> add(MomoTransaction transaction, {DateTime? createdAt}) {
    return _transactions.add({
      ...transaction.toMap(),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt),
    });
  }

  Future<void> update(MomoTransaction transaction) {
    return _transactions.doc(transaction.id).update(transaction.toMap());
  }

  Future<void> delete(String id) {
    return _transactions.doc(id).delete();
  }

  // Undo writes the same transaction back under the same id.
  Future<void> restore(MomoTransaction transaction) {
    return _transactions.doc(transaction.id).set({
      ...transaction.toMap(),
      'createdAt': transaction.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(transaction.createdAt!),
    });
  }

  // Sample data for a brand new account.
  // Times are one second apart so newest-first has a stable order.
  Future<void> addSamples() async {
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
      batch.set(_transactions.doc(), {
        ...samples[i].toMap(),
        'createdAt': Timestamp.fromDate(now.add(Duration(seconds: i))),
      });
    }
    await batch.commit();
  }
}
