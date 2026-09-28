import 'package:flutter_test/flutter_test.dart';
import 'package:pet_finance/services/period_config_service.dart';
import 'package:pet_finance/models/purchase.dart';

void main() {
  group('PeriodConfigService', () {
    final service = PeriodConfigService();

    test('создаёт все 5 периодов с правильным доходом', () {
      final expectedIncomes = {
        1: 100,
        2: 120,
        3: 130,
        4: 140,
        5: 150,
      };

      for (final entry in expectedIncomes.entries) {
        final period = service.createPeriod(entry.key);

        expect(period.number, entry.key);
        expect(period.income, entry.value);
        expect(period.completed, false);
      }
    });

    test('каждый период имеет свои покупки', () {
      for (int number = 1; number <= 5; number++) {
        final config = service.getConfig(number);

        expect(config.purchases, isNotEmpty);

        for (final purchase in config.purchases) {
          expect(purchase.period, number);
        }
      }
    });

    test('в каждом периоде есть обязательная и необязательная покупка', () {
      for (int number = 1; number <= 5; number++) {
        final config = service.getConfig(number);

        final hasMandatory = config.purchases.any(
              (purchase) => purchase.category == PurchaseCategory.mandatory,
        );

        final hasOptional = config.purchases.any(
              (purchase) => purchase.category == PurchaseCategory.optional,
        );

        expect(hasMandatory, true);
        expect(hasOptional, true);
      }
    });
  });
}