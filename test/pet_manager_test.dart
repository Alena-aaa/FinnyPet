import 'package:flutter_test/flutter_test.dart';
import 'package:pet_finance/game/pet/pet.dart';
import 'package:pet_finance/game/pet/pet_manager.dart';
import 'package:pet_finance/game/pet/in_memory_pet_storage.dart';
import 'package:pet_finance/game/pet/pet_rules.dart';

void main() {
  late PetManager manager;

  setUp(() {
    manager = PetManager(storage: InMemoryPetStorage());
  });

  test('createPet ставит стартовые значения', () async {
    final pet = await manager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.black,
      name: 'Барсик',
    );
    expect(pet.mood, PetRules.startMood);
    expect(pet.satiety, PetRules.startSatiety);
    expect(pet.care, PetRules.startCare);
    expect(pet.growthPoints, 0);
    expect(pet.growthStage, GrowthStage.baby);
  });

  test('createPet падает на пустом имени', () async {
    expect(
      () => manager.createPet(
        id: '1',
        type: PetType.cat,
        color: PetColor.black,
        name: '   ',
      ),
      throwsA(isA<PetException>()),
    );
  });

  test('feed не превышает 100', () async {
    await manager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.black,
      name: 'Барсик',
    );
    var pet = await manager.feed();
    expect(pet.satiety, 90);

    pet = await manager.feed();
    expect(pet.satiety, 100);
  });

  test('play не уходит ниже 0', () async {
    await manager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.black,
      name: 'Барсик',
    );
    final pet = await manager.play();
    expect(pet.satiety, 65);
    expect(pet.mood, 85);
  });

  test('applyEffect меняет нужное поле', () async {
    await manager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.black,
      name: 'Барсик',
    );
    final pet = await manager.applyEffect('mood', 10);
    expect(pet.mood, 80);
  });

  test('applyEffect падает на неизвестном поле', () async {
    await manager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.black,
      name: 'Барсик',
    );
    expect(
      () => manager.applyEffect('unknown', 10),
      throwsA(isA<PetException>()),
    );
  });

  test('addGrowthPoints пересчитывает стадию', () async {
    await manager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.black,
      name: 'Барсик',
    );
    var pet = await manager.addGrowthPoints(3);
    expect(pet.growthStage, GrowthStage.teen);
    pet = await manager.addGrowthPoints(3);
    expect(pet.growthStage, GrowthStage.adult);
  });

  test('addGrowthPoints падает на отрицательных', () async {
    await manager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.black,
      name: 'Барсик',
    );
    expect(
      () => manager.addGrowthPoints(-1),
      throwsA(isA<PetException>()),
    );
  });

  test('resetPet очищает', () async {
    await manager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.black,
      name: 'Барсик',
    );
    await manager.resetPet();
    expect(manager.getPet(), isNull);
  });
}

