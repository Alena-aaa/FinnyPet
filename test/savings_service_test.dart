import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/player.dart';
import 'package:pet_finance/models/savings_goal.dart';
import 'package:pet_finance/models/transaction.dart';
import 'package:pet_finance/services/savings_service.dart';

void main() {
  test('Накопление списывает деньги и увеличивает сумму цели', () {
    final service = SavingsService();

    final player = Player(
      id: '1',
      name: 'Мурка',
      currentBalance: 100,
      currentPeriod: 1,
    );

    final goal = SavingsGoal(
      id: 'bike',
      name: 'Велосипед',
      targetAmount: 200,
      savedAmount: 0,
    );

    final transaction = service.saveMoney(
      player: player,
      goal: goal,
      amount: 30,
      period: 1,
    );

    expect(player.currentBalance, 70);
    expect(goal.savedAmount, 30);

    expect(transaction, isNotNull);
    expect(transaction!.type, TransactionType.saving);
    expect(transaction.amount, 30);
    expect(transaction.source, 'Велосипед');
    expect(transaction.period, 1);
  });

  test('Накопление добавляется к уже накопленной сумме', () {
    final service = SavingsService();

    final player = Player(
      id: '1',
      name: 'Мурка',
      currentBalance: 100,
      currentPeriod: 1,
    );

    final goal = SavingsGoal(
      id: 'bike',
      name: 'Велосипед',
      targetAmount: 200,
      savedAmount: 50,
    );

    final transaction = service.saveMoney(
      player: player,
      goal: goal,
      amount: 30,
      period: 1,
    );

    expect(transaction, isNotNull);
    expect(player.currentBalance, 70);
    expect(goal.savedAmount, 80);
  });

  test('Накопление не проходит при недостатке денег', () {
    final service = SavingsService();

    final player = Player(
      id: '1',
      name: 'Мурка',
      currentBalance: 20,
      currentPeriod: 1,
    );

    final goal = SavingsGoal(
      id: 'bike',
      name: 'Велосипед',
      targetAmount: 200,
      savedAmount: 50,
    );

    final transaction = service.saveMoney(
      player: player,
      goal: goal,
      amount: 30,
      period: 1,
    );

    expect(transaction, isNull);
    expect(player.currentBalance, 20);
    expect(goal.savedAmount, 50);
  });
}