import 'package:flutter_test/flutter_test.dart';
import 'package:pet_finance/game/pet/pet.dart';
import 'package:pet_finance/game/pet/pet_rules.dart';
import 'package:pet_finance/game/growth/growth_manager.dart';

void main() {
  late GrowthManager growth;

  setUp(() {
    growth = GrowthManager();
  });

  // ---------- calculateStage ----------

  test('0 очков → baby', () {
    expect(growth.calculateStage(0), GrowthStage.baby);
  });

  test('2 очка → baby', () {
    expect(growth.calculateStage(2), GrowthStage.baby);
  });

  test('3 очка → teen', () {
    expect(growth.calculateStage(3), GrowthStage.teen);
  });

  test('5 очков → teen', () {
    expect(growth.calculateStage(5), GrowthStage.teen);
  });

  test('6 очков → adult', () {
    expect(growth.calculateStage(6), GrowthStage.adult);
  });

  test('10 очков → adult', () {
    expect(growth.calculateStage(10), GrowthStage.adult);
  });

  // ---------- nextStageThreshold ----------

  test('baby: следующая стадия на 3', () {
    expect(growth.nextStageThreshold(0), PetRules.teenThreshold);
    expect(growth.nextStageThreshold(2), PetRules.teenThreshold);
  });

  test('teen: следующая стадия на 6', () {
    expect(growth.nextStageThreshold(3), PetRules.adultThreshold);
    expect(growth.nextStageThreshold(5), PetRules.adultThreshold);
  });

  test('adult: следующей стадии нет', () {
    expect(growth.nextStageThreshold(6), isNull);
    expect(growth.nextStageThreshold(10), isNull);
  });

  // ---------- progressToNextStage ----------

  test('baby, 0 очков → прогресс 0.0', () {
    expect(growth.progressToNextStage(0), 0.0);
  });

  test('baby, 1 очко → 1/3 ≈ 0.33', () {
    expect(growth.progressToNextStage(1), closeTo(1 / 3, 0.01));
  });

  test('teen, 3 очка → 0.0', () {
    expect(growth.progressToNextStage(3), 0.0);
  });

  test('teen, 5 очков → 2/3 ≈ 0.66', () {
    expect(growth.progressToNextStage(5), closeTo(2 / 3, 0.01));
  });

  test('adult → прогресс 1.0', () {
    expect(growth.progressToNextStage(6), 1.0);
    expect(growth.progressToNextStage(100), 1.0);
  });
}

