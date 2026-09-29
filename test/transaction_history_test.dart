import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/transaction.dart';
import 'package:pet_finance/services/transaction_history.dart';

void main() {
  test('TransactionHistory сохраняет транзакцию', () {
    final history = TransactionHistory();

    final transaction = Transaction(
      type: TransactionType.optional,
      amount: 25,
      source: 'Мороженое',
      period: 1,
      timestamp: DateTime(2026, 9, 23),
    );

    history.add(transaction);

    expect(history.transactions.length, 1);
    expect(history.transactions.first, transaction);
  });

  test('TransactionHistory возвращает транзакции нужного периода', () {
    final history = TransactionHistory();

    final period1 = Transaction(
      type: TransactionType.mandatory,
      amount: 50,
      source: 'Еда',
      period: 1,
      timestamp: DateTime(2026, 9, 23),
    );

    final period2 = Transaction(
      type: TransactionType.optional,
      amount: 20,
      source: 'Игрушка',
      period: 2,
      timestamp: DateTime(2026, 9, 23),
    );

    history.add(period1);
    history.add(period2);

    final result = history.getByPeriod(1);

    expect(result.length, 1);
    expect(result.first.source, 'Еда');
  });
}

