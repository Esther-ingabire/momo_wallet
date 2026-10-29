import 'package:cloud_firestore/cloud_firestore.dart';

class MomoTransaction {
  MomoTransaction({
    this.id = '',
    required this.description,
    required this.amount,
    required this.isIn,
    this.createdAt,
  });

  final String id;
  final String description;
  final int amount;

  // True when money comes in. False when money goes out.
  final bool isIn;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {'description': description, 'amount': amount, 'isIn': isIn};
  }

  factory MomoTransaction.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MomoTransaction(
      id: doc.id,
      description: data['description'] as String,
      amount: (data['amount'] as num).toInt(),
      isIn: data['isIn'] as bool,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
