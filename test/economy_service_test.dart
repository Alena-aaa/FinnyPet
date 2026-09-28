import 'package:flutter_test/flutter_test.dart';
import 'package:pet_finance/models/budget_plan.dart';

import 'package:pet_finance/models/player.dart';
import 'package:pet_finance/services/economy_service.dart';

import 'package:pet_finance/models/savings_goal.dart';
import 'package:pet_finance/models/transaction.dart';

void main() {
  test('addMoney increases balance', () {
    final player =Player(
      id:'player_1',
      name: 'Anna',
      currentBalance: 100,
      currentPeriod: 1,
    );
    final economy = EconomyService();
    economy.addMoney(player, 50);
    expect(player.currentBalance, 150);
  });

  test('spendMoney spends Moneyy', () {
    final player =Player(
      id:'player_1',
      name: 'Anna',
      currentBalance: 100,
      currentPeriod: 1,
    );
    final economy = EconomyService();
    final result = economy.spendMoney(player, 30);
    expect(result, true);
    expect(player.currentBalance, 70);
  });

  test('spendMoney doesnt spend money((', () {
    final player =Player(
      id:'player_1',
      name: 'Anna',
      currentBalance: 100,
      currentPeriod: 1,
    );
    final economy = EconomyService();
    final result = economy.spendMoney(player, 150);
    expect(result, false);
    expect(player.currentBalance, 100);
  });

  test('isPlanValid is valid', () {
    final player =Player(
      id:'player_1',
      name: 'Anna',
      currentBalance: 100,
      currentPeriod: 1,
    );
    final plan = BudgetPlan(
        mandatory: 50,
        optional: 20,
        savings: 30,
    );
    final economy = EconomyService();
    expect(economy.isPlanValid(player, plan), true);
  });

  test('isPlanValid isnt valid', () {
    final player =Player(
      id:'player_1',
      name: 'Anna',
      currentBalance: 100,
      currentPeriod: 1,
    );
    final plan = BudgetPlan(
      mandatory: 70,
      optional: 40,
      savings: 50,
    );
    final economy = EconomyService();
    expect(economy.isPlanValid(player, plan), false);
  });

  test('saveMoney переводит деньги в накопления', () {
    final player = Player(
      id: 'player_1',
      name: 'Маша',
      currentBalance: 100,
      currentPeriod: 1,
    );

    final goal = SavingsGoal(
      id: 'goal_1',
      name: 'Велосипед',
      targetAmount: 300,
      savedAmount: 50,
    );

    final economy = EconomyService();

    final result = economy.saveMoney(player, goal, 30);

    expect(result, true);
    expect(player.currentBalance, 70);
    expect(goal.savedAmount, 80);
  });

  test('createExpenseTransaction создаёт транзакцию', () {
    final economy = EconomyService();

    final transaction = economy.createExpenseTransaction(
      type: TransactionType.optional,
      amount: 25,
      source: 'Мороженое',
      period: 1,
    );

    expect(transaction, isNotNull);
    expect(transaction!.type, TransactionType.optional);
    expect(transaction.amount, 25);
    expect(transaction.source, 'Мороженое');
    expect(transaction.period, 1);
  });

  test('spendMoneyWithTransaction списывает деньги и создаёт транзакцию', () {
    final player = Player(
      id: 'player_1',
      name: 'Маша',
      currentBalance: 100,
      currentPeriod: 1,
    );

    final economy = EconomyService();

    final transaction = economy.spendMoneyWithTransaction(
      player: player,
      amount: 25,
      type: TransactionType.optional,
      source: 'Мороженое',
      period: 1,
    );

    expect(transaction, isNotNull);
    expect(player.currentBalance, 75);
    expect(transaction!.type, TransactionType.optional);
    expect(transaction.amount, 25);
    expect(transaction.source, 'Мороженое');
    expect(transaction.period, 1);
  });

  test('spendMoneyWithTransaction не тратит деньги при недостатке средств', () {
    final player = Player(
      id: 'player_1',
      name: 'Маша',
      currentBalance: 10,
      currentPeriod: 1,
    );

    final economy = EconomyService();

    final transaction = economy.spendMoneyWithTransaction(
      player: player,
      amount: 25,
      type: TransactionType.optional,
      source: 'Мороженое',
      period: 1,
    );

    expect(transaction, isNull);
    expect(player.currentBalance, 10);
  });

  test('saveMoneyWithTransaction переводит деньги в цель и создаёт транзакцию', () {
    final player = Player(
      id: 'player_1',
      name: 'Маша',
      currentBalance: 100,
      currentPeriod: 1,
    );

    final goal = SavingsGoal(
      id: 'goal_1',
      name: 'Велосипед',
      targetAmount: 300,
      savedAmount: 50,
    );

    final economy = EconomyService();

    final transaction = economy.saveMoneyWithTransaction(
      player: player,
      goal: goal,
      amount: 30,
      period: 1,
    );

    expect(transaction, isNotNull);
    expect(player.currentBalance, 70);
    expect(goal.savedAmount, 80);
    expect(transaction!.type, TransactionType.saving);
    expect(transaction.amount, 30);
    expect(transaction.source, 'Велосипед');
    expect(transaction.period, 1);
  });

  test('saveMoneyWithTransaction не переводит деньги при недостатке средств', () {
    final player = Player(
      id: 'player_1',
      name: 'Маша',
      currentBalance: 10,
      currentPeriod: 1,
    );

    final goal = SavingsGoal(
      id: 'goal_1',
      name: 'Велосипед',
      targetAmount: 300,
      savedAmount: 50,
    );

    final economy = EconomyService();

    final transaction = economy.saveMoneyWithTransaction(
      player: player,
      goal: goal,
      amount: 30,
      period: 1,
    );

    expect(transaction, isNull);
    expect(player.currentBalance, 10);
    expect(goal.savedAmount, 50);
  });


}