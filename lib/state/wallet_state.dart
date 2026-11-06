import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:momo_wallet/logic/wallet_rules.dart';
import 'package:momo_wallet/models/momo_transaction.dart';
import 'package:momo_wallet/repositories/photo_repository.dart';
import 'package:momo_wallet/repositories/transaction_repository.dart';

// The brain. Screens watch this class. They do not keep their own copy
// of the transactions.
class WalletState extends ChangeNotifier {
  WalletState(this._repo, this._photos) {
    // Born: open the pipe to Firestore once, for this user only.
    _subscription = _repo.watchAll().listen(
      (list) {
        _transactions = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _loading = false;
        _error = _loadError(error);
        notifyListeners();
      },
    );
  }

  final TransactionRepository _repo;
  final PhotoRepository _photos;
  StreamSubscription<List<MomoTransaction>>? _subscription;

  // Private: only this class can change the list.
  List<MomoTransaction> _transactions = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  List<MomoTransaction> get transactions => _transactions;
  bool get loading => _loading;
  String? get error => _error;
  String get filter => _filter;

  // Worked out every time a screen reads it. Never saved.
  WalletStats get stats => statsFor(_transactions);
  int get balance => stats.balance;

  // The rows the chips are showing. The balance still uses every transaction.
  List<MomoTransaction> get visible =>
      visibleTransactions(_transactions, _filter);

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  Future<String> uploadPhoto(File photo) => _photos.upload(photo);

  Future<void> add(MomoTransaction transaction, {DateTime? createdAt}) {
    return _repo.add(transaction, createdAt: createdAt);
  }

  Future<void> edit(MomoTransaction transaction) {
    return _repo.update(transaction);
  }

  Future<void> remove(MomoTransaction transaction) {
    return _repo.delete(transaction.id);
  }

  Future<void> restore(MomoTransaction transaction) {
    return _repo.restore(transaction);
  }

  static String _loadError(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('permission-denied')) {
      return 'Firestore blocked this account. Open Firestore, then Rules, and publish the users rule.';
    }
    if (text.contains('unavailable') || text.contains('network')) {
      return 'The phone has no internet. Turn Wi-Fi on, then Stop and Run.';
    }
    return 'Could not load your transactions.\n$error';
  }

  @override
  void dispose() {
    // Log out closes the pipe, so we stop listening to the old account.
    _subscription?.cancel();
    super.dispose();
  }
}
