import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/transaction.dart';

void main() {
  test('Transaction сохраняет данные операции', () {
    final transaction = Transaction(
      type: TransactionType.saving,
      amount: 30,
      source: 'Велосипед',
      period: 1,
      timestamp: DateTime(2026, 9, 23),
    );

    expect(transaction.type, TransactionType.saving);
    expect(transaction.amount, 30);
    expect(transaction.source, 'Велосипед');
    expect(transaction.period, 1);
    expect(transaction.timestamp, DateTime(2026, 9, 23));
  });
}

