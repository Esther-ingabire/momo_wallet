import 'package:cloud_firestore/cloud_firestore.dart';

class MomoTransaction {
  MomoTransaction({
    this.id = '',
    required this.description,
    required this.amount,
    required this.isIn,
    this.createdAt,
    this.photoUrl,
  });

  final String id;
  final String description;
  final int amount;

  // True when money comes in. False when money goes out.
  final bool isIn;
  final DateTime? createdAt;

  // A link to the receipt photo, or null when this payment has no photo.
  final String? photoUrl;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'isIn': isIn,
      'photoUrl': photoUrl,
    };
  }

  factory MomoTransaction.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MomoTransaction(
      id: doc.id,
      description: data['description']?.toString() ?? '',
      amount: _readAmount(data['amount']),
      isIn: data['isIn'] == true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      photoUrl: data['photoUrl'] is String ? data['photoUrl'] as String : null,
    );
  }

  static int _readAmount(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
