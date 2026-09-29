import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/budget_plan.dart';
import 'package:pet_finance/models/period_fact.dart';
import 'package:pet_finance/services/growth_service.dart';

void main() {
  test('GrowthService даёт очки за обязательные расходы, план и накопления', () {
    final service = GrowthService();

    final facts = [
      PeriodFact(
        mandatory: 30,
        optional: 20,
        savings: 30,
        plan: BudgetPlan(
          mandatory: 30,
          optional: 20,
          savings: 50,
        ),
      ),
    ];

    final points = service.calculateGrowthPoints(facts);

    expect(points, 3);
  });

  test('GrowthService даёт очко за соответствие плану', () {
    final service = GrowthService();

    final facts = [
      PeriodFact(
        mandatory: 0,
        optional: 10,
        savings: 20,
        plan: BudgetPlan(
          mandatory: 30,
          optional: 20,
          savings: 50,
        ),
      ),
    ];

    final points = service.calculateGrowthPoints(facts);

    expect(points, 2);
  });

  test('GrowthService не даёт очко за превышение плана', () {
    final service = GrowthService();

    final facts = [
      PeriodFact(
        mandatory: 40,
        optional: 30,
        savings: 20,
        plan: BudgetPlan(
          mandatory: 30,
          optional: 20,
          savings: 50,
        ),
      ),
    ];

    final points = service.calculateGrowthPoints(facts);

    expect(points, 2);
  });

  test('GrowthService суммирует очки нескольких периодов', () {
    final service = GrowthService();

    final facts = [
      PeriodFact(
        mandatory: 30,
        optional: 10,
        savings: 20,
        plan: BudgetPlan(
          mandatory: 30,
          optional: 20,
          savings: 50,
        ),
      ),
      PeriodFact(
        mandatory: 0,
        optional: 10,
        savings: 30,
        plan: BudgetPlan(
          mandatory: 30,
          optional: 20,
          savings: 50,
        ),
      ),
    ];

    final points = service.calculateGrowthPoints(facts);

    expect(points, 5);
  });
}