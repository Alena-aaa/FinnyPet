import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/game_period.dart';
import 'package:pet_finance/models/budget_plan.dart';

void main() {
  test('GamePeriod создаётся с начальными значениями', () {
    final period = GamePeriod(
      number: 1,
      income: 100,
    );

    expect(period.number, 1);
    expect(period.income, 100);
    expect(period.budgetPlan, isNull);
    expect(period.actualMandatory, 0);
    expect(period.actualOptional, 0);
    expect(period.actualSavings, 0);
    expect(period.completed, false);
  });

  test('GamePeriod хранит бюджет и факт периода', () {
    final plan = BudgetPlan(
      mandatory: 50,
      optional: 20,
      savings: 30,
    );

    final period = GamePeriod(
      number: 2,
      income: 120,
      budgetPlan: plan,
      actualMandatory: 50,
      actualOptional: 25,
      actualSavings: 20,
      completed: true,
    );

    expect(period.number, 2);
    expect(period.income, 120);
    expect(period.budgetPlan, plan);
    expect(period.actualMandatory, 50);
    expect(period.actualOptional, 25);
    expect(period.actualSavings, 20);
    expect(period.completed, true);
  });
}