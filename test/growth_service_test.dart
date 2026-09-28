import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/period_fact.dart';
import 'package:pet_finance/services/growth_service.dart';

void main() {
  test('GrowthService даёт 1 growth point за хороший период', () {
    final service = GrowthService();

    final fact = PeriodFact(
      mandatory: 50,
      optional: 20,
      savings: 30,
    );

    final points = service.calculateGrowthPoints(fact);

    expect(points, 1);
  });

  test('GrowthService не даёт growth point без накоплений', () {
    final service = GrowthService();

    final fact = PeriodFact(
      mandatory: 50,
      optional: 20,
      savings: 0,
    );

    final points = service.calculateGrowthPoints(fact);

    expect(points, 0);
  });

  test('GrowthService не даёт growth point если накоплено меньше 10', () {
    final service = GrowthService();

    final fact = PeriodFact(
      mandatory: 50,
      optional: 20,
      savings: 9,
    );

    final points = service.calculateGrowthPoints(fact);

    expect(points, 0);
  });
}