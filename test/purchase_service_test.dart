import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/player.dart';
import 'package:pet_finance/models/purchase.dart';
import 'package:pet_finance/models/transaction.dart';
import 'package:pet_finance/services/purchase_service.dart';

void main() {
  test('Покупка обязательного товара списывает деньги и создаёт транзакцию', () {
    final service = PurchaseService();

    final player = Player(
      id: '1',
      name: 'Мурка',
      currentBalance: 100,
      currentPeriod: 1,
    );

    final purchase = Purchase(
      id: 'food',
      name: 'Еда',
      price: 30,
      category: PurchaseCategory.mandatory,
      period: 1,
    );

    final transaction = service.buyPurchase(
      player: player,
      purchase: purchase,
    );

    expect(player.currentBalance, 70);
    expect(transaction, isNotNull);
    expect(transaction!.type, TransactionType.mandatory);
    expect(transaction.amount, 30);
    expect(transaction.source, 'Еда');
    expect(transaction.period, 1);
  });

  test('Покупка необязательного товара создаёт optional-транзакцию', () {
    final service = PurchaseService();

    final player = Player(
      id: '1',
      name: 'Мурка',
      currentBalance: 100,
      currentPeriod: 1,
    );

    final purchase = Purchase(
      id: 'toy',
      name: 'Игрушка',
      price: 20,
      category: PurchaseCategory.optional,
      period: 1,
    );

    final transaction = service.buyPurchase(
      player: player,
      purchase: purchase,
    );

    expect(player.currentBalance, 80);
    expect(transaction, isNotNull);
    expect(transaction!.type, TransactionType.optional);
    expect(transaction.amount, 20);
  });

  test('Покупка не проходит при недостатке денег', () {
    final service = PurchaseService();

    final player = Player(
      id: '1',
      name: 'Мурка',
      currentBalance: 10,
      currentPeriod: 1,
    );

    final purchase = Purchase(
      id: 'toy',
      name: 'Игрушка',
      price: 20,
      category: PurchaseCategory.optional,
      period: 1,
    );

    final transaction = service.buyPurchase(
      player: player,
      purchase: purchase,
    );

    expect(transaction, isNull);
    expect(player.currentBalance, 10);
  });
}