import 'package:momo_wallet/models/momo_transaction.dart';

// Money the wallet already holds before the first transaction.
const int openingBalance = 10000;

// Every successful send also records this fee as its own OUT.
const int sendFee = 100;

const List<int> cashNotes = [5000, 2000, 1000, 500, 100];

class NoteLine {
  NoteLine(this.value, this.count);

  final int value;
  final int count;
}

class WalletStats {
  WalletStats({
    required this.balance,
    required this.totalIn,
    required this.totalOut,
    required this.lowestBalance,
  });

  final int balance;
  final int totalIn;
  final int totalOut;
  final int lowestBalance;
}

// Newest first, so the wallet list can show this list as it is.
List<MomoTransaction> sampleTransactions() {
  return [
    MomoTransaction(
      description: 'Received from Aline',
      amount: 1500,
      isIn: true,
    ),
    MomoTransaction(description: 'Cash out', amount: 9000, isIn: false),
    MomoTransaction(
      description: 'Received from Eric',
      amount: 8000,
      isIn: true,
    ),
    MomoTransaction(
      description: 'Sent to 0781112233',
      amount: 4000,
      isIn: false,
    ),
  ];
}

WalletStats statsFor(List<MomoTransaction> newestFirst) {
  var balance = openingBalance;
  // Not 0. The wallet already holds the opening balance, and a later
  // balance only replaces this when it is actually smaller.
  var lowest = openingBalance;
  var totalIn = 0;
  var totalOut = 0;

  for (final transaction in newestFirst.reversed) {
    if (transaction.isIn) {
      balance += transaction.amount;
      totalIn += transaction.amount;
    } else {
      balance -= transaction.amount;
      totalOut += transaction.amount;
    }
    if (balance < lowest) lowest = balance;
  }

  return WalletStats(
    balance: balance,
    totalIn: totalIn,
    totalOut: totalOut,
    lowestBalance: lowest,
  );
}

List<MomoTransaction> visibleTransactions(
  List<MomoTransaction> transactions,
  String filter,
) {
  if (filter == 'IN') {
    return transactions.where((transaction) => transaction.isIn).toList();
  }
  if (filter == 'OUT') {
    return transactions.where((transaction) => !transaction.isIn).toList();
  }
  return transactions;
}

String? phoneProblem(String raw) {
  final phone = raw.trim();
  if (phone.length != 10 || !_digitsOnly(phone)) {
    return 'Phone number must be exactly 10 digits';
  }
  if (!phone.startsWith('078') && !phone.startsWith('079')) {
    return 'Phone number must start with 078 or 079';
  }
  return null;
}

String? sendAmountProblem(String raw, int balance) {
  final amount = int.tryParse(raw.trim());
  if (amount == null) {
    return 'Amount must be a whole number, like 500';
  }
  if (amount < 100) {
    return 'Amount must be at least 100 RWF';
  }
  if (amount + sendFee > balance) {
    return 'Insufficient balance';
  }
  return null;
}

String? receiveProblem(String description, String rawAmount) {
  if (description.trim().isEmpty) {
    return 'Description cannot be empty';
  }
  final amount = int.tryParse(rawAmount.trim());
  if (amount == null) {
    return 'Amount must be a whole number, like 500';
  }
  if (amount <= 0) {
    return 'Amount must be a whole number above 0';
  }
  return null;
}

String? cashOutAmountProblem(String raw) {
  final amount = int.tryParse(raw.trim());
  if (amount == null) {
    return 'Amount must be a whole number, like 500';
  }
  if (amount <= 0) {
    return 'Amount must be a whole number above 0';
  }
  if (amount % 100 != 0) {
    return 'Amount must be a multiple of 100';
  }
  return null;
}

String? cashOutBalanceProblem(int amount, int balance) {
  if (amount > balance) return 'Insufficient balance';
  return null;
}

// Null when the agent cannot make this amount with the notes on hand.
List<NoteLine>? notesFor(int amount) {
  if (cashOutAmountProblem('$amount') != null) return null;
  var left = amount;
  final lines = <NoteLine>[];
  for (final value in cashNotes) {
    final count = left ~/ value;
    if (count > 0) {
      lines.add(NoteLine(value, count));
      left -= count * value;
    }
  }
  if (left != 0) return null;
  return lines;
}

String? deleteProblem(
  List<MomoTransaction> newestFirst,
  MomoTransaction target,
) {
  var balance = openingBalance;
  for (final transaction in newestFirst.reversed) {
    if (identical(transaction, target)) continue;
    if (transaction.isIn) {
      balance += transaction.amount;
    } else {
      balance -= transaction.amount;
    }
    if (balance < 0) {
      return 'Cannot delete this. The balance would go below 0';
    }
  }
  return null;
}

String rwf(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final digitsLeft = digits.length - i;
    if (i > 0 && digitsLeft % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  if (amount < 0) return '-$buffer';
  return buffer.toString();
}

String notesText(List<NoteLine> lines) {
  return lines.map((line) => '${rwf(line.value)} × ${line.count}').join(' · ');
}

bool _digitsOnly(String text) {
  for (var i = 0; i < text.length; i++) {
    final code = text.codeUnitAt(i);
    if (code < 48 || code > 57) return false;
  }
  return true;
}
