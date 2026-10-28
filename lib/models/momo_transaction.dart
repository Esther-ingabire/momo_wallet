class MomoTransaction {
  MomoTransaction({
    required this.description,
    required this.amount,
    required this.isIn,
  });

  final String description;
  final int amount;

  // True when money comes in. False when money goes out.
  final bool isIn;

  Map<String, dynamic> toJson() {
    return {'description': description, 'amount': amount, 'isIn': isIn};
  }

  factory MomoTransaction.fromJson(Map<String, dynamic> json) {
    return MomoTransaction(
      description: json['description'] as String,
      amount: (json['amount'] as num).toInt(),
      isIn: json['isIn'] as bool,
    );
  }
}
