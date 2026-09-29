import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/models/period_fact.dart';
import 'package:pet_finance/services/growth_service.dart';

void main() {
  test('GrowthService считает очки по нескольким завершённым периодам', () {
    final service = GrowthService();

    final facts = [
      PeriodFact(
        mandatory: 50,
        optional: 20,
        savings: 30,
      ),
      PeriodFact(
        mandatory: 40,
        optional: 25,
        savings: 0,
      ),
    ];

    final points = service.calculateGrowthPoints(facts);

    expect(points, 3);
  });

  test('GrowthService не даёт очко за накопления меньше 10', () {
    final service = GrowthService();

    final facts = [
      PeriodFact(
        mandatory: 50,
        optional: 20,
        savings: 9,
      ),
    ];

    final points = service.calculateGrowthPoints(facts);

    expect(points, 1);
  });

  test('GrowthService считает каждый завершённый период отдельно', () {
    final service = GrowthService();

    final facts = [
      PeriodFact(
        mandatory: 0,
        optional: 20,
        savings: 0,
      ),
      PeriodFact(
        mandatory: 30,
        optional: 10,
        savings: 20,
      ),
    ];

    final points = service.calculateGrowthPoints(facts);

    expect(points, 2);
  });
}