import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/transaction.dart';
import 'package:pet_finance/services/period_service.dart';

import 'package:pet_finance/models/budget_plan.dart';
import 'package:pet_finance/models/period_fact.dart';
import 'package:pet_finance/models/game_period.dart';

void main() {
  test('PeriodService считает фактические расходы по категориям', () {
    final service = PeriodService();

    final transactions = [
      Transaction(
        type: TransactionType.mandatory,
        amount: 50,
        source: 'Еда',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
      Transaction(
        type: TransactionType.optional,
        amount: 20,
        source: 'Игрушка',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
      Transaction(
        type: TransactionType.optional,
        amount: 15,
        source: 'Мороженое',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
      Transaction(
        type: TransactionType.saving,
        amount: 30,
        source: 'Велосипед',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
      Transaction(
        type: TransactionType.income,
        amount: 120,
        source: 'Награда',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
    ];

    final fact = service.calculateFact(transactions);

    expect(fact.mandatory, 50);
    expect(fact.optional, 35);
    expect(fact.savings, 30);
  });

  test('PeriodService сравнивает план и факт', () {
    final service = PeriodService();

    final plan = BudgetPlan(
      mandatory: 50,
      optional: 20,
      savings: 30,
    );

    final fact = PeriodFact(
      mandatory: 50,
      optional: 35,
      savings: 15,
    );

    final result = service.comparePlanAndFact(
      plan,
      fact,
      1,
    );

    expect(result.mandatoryDifference, 0);
    expect(result.optionalDifference, 15);
    expect(result.savingsDifference, -15);
    expect(result.growthPoints, 1);
  });

  test('completePeriod записывает факт и завершает период', () {
    final service = PeriodService();

    final period = GamePeriod(
      number: 1,
      income: 100,
      budgetPlan: BudgetPlan(
        mandatory: 50,
        optional: 20,
        savings: 30,
      ),
    );

    final transactions = [
      Transaction(
        type: TransactionType.mandatory,
        amount: 50,
        source: 'Еда',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
      Transaction(
        type: TransactionType.optional,
        amount: 35,
        source: 'Игрушки',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
      Transaction(
        type: TransactionType.saving,
        amount: 15,
        source: 'Велосипед',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
    ];

    final result = service.completePeriod(
      period: period,
      transactions: transactions,
    );

    expect(result, isNotNull);
    expect(result!.mandatoryDifference, 0);
    expect(result.optionalDifference, 15);
    expect(result.savingsDifference, -15);
    expect(result.growthPoints, 1);

    expect(period.actualMandatory, 50);
    expect(period.actualOptional, 35);
    expect(period.actualSavings, 15);
    expect(period.completed, true);
  });

  test('completePeriod не завершает период без бюджета', () {
    final service = PeriodService();

    final period = GamePeriod(
      number: 1,
      income: 100,
    );

    final transactions = <Transaction>[];

    final result = service.completePeriod(
      period: period,
      transactions: transactions,
    );

    expect(result, isNull);
    expect(period.completed, false);
  });

  test('completePeriod не завершает период при перерасходе', () {
    final service = PeriodService();

    final period = GamePeriod(
      number: 1,
      income: 100,
      budgetPlan: BudgetPlan(
        mandatory: 50,
        optional: 30,
        savings: 20,
      ),
    );

    final transactions = [
      Transaction(
        type: TransactionType.mandatory,
        amount: 60,
        source: 'Еда',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
      Transaction(
        type: TransactionType.optional,
        amount: 50,
        source: 'Игрушка',
        period: 1,
        timestamp: DateTime(2026, 9, 25),
      ),
    ];

    final result = service.completePeriod(
      period: period,
      transactions: transactions,
    );

    expect(result, isNull);
    expect(period.completed, false);
  });
}