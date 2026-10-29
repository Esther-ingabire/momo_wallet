import 'package:flutter_test/flutter_test.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';

void main() {
  test('balance is worked out from the transactions', () {
    final newestFirst = [
      MomoTransaction(
        description: 'Received from Keza',
        amount: 4000,
        isIn: true,
      ),
      MomoTransaction(
        description: 'Sent to 0788123456',
        amount: 2500,
        isIn: false,
      ),
      MomoTransaction(
        description: 'Opening balance',
        amount: 10000,
        isIn: true,
      ),
    ];

    final stats = statsFor(newestFirst);

    expect(stats.balance, 11500);
    expect(stats.totalIn, 14000);
    expect(stats.totalOut, 2500);
    expect(stats.lowestBalance, 7500);
  });
}
