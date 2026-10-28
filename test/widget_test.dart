import 'package:flutter_test/flutter_test.dart';
import 'package:momo_wallet/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('wallet shows the sample balance', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SawaApp());
    await tester.pump();

    expect(find.text('Sawa Wallet'), findsOneWidget);
    expect(find.text('6,500 RWF'), findsOneWidget);
  });
}
