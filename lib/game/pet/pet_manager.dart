import 'pet.dart';
import 'pet_rules.dart';
import 'pet_storage.dart';

/// Ошибки PetManager.
class PetException implements Exception {
  final String message;
  PetException(this.message);
  @override
  String toString() => 'PetException: $message';
}

class PetManager {
  final PetStorage _storage;
  Pet? _pet;

  PetManager({required PetStorage storage}) : _storage = storage;

  // ---------- СОЗДАНИЕ ----------

  /// Создаёт питомца. id генерируется снаружи (например, uuid).
  Future<Pet> createPet({
    required String id,
    required PetType type,
    required PetColor color,
    required String name,
  }) async {
    if (name.trim().isEmpty) {
      throw PetException('Имя питомца не может быть пустым');
    }

    final pet = Pet(
      id: id,
      type: type,
      color: color,
      name: name.trim(),
      mood: PetRules.startMood,
      satiety: PetRules.startSatiety,
      care: PetRules.startCare,
      growthPoints: 0,
      growthStage: GrowthStage.baby,
    );

    _pet = pet;
    await _storage.save(pet);
    return pet;
  }

  // ---------- ЧТЕНИЕ ----------

  Pet? getPet() => _pet;

  Future<Pet?> loadPet() async {
    _pet = await _storage.load();
    return _pet;
  }

  // ---------- СОХРАНЕНИЕ ----------

  Future<void> savePet() async {
    final pet = _pet;
    if (pet == null) {
      throw PetException('Нельзя сохранить: питомец не создан');
    }
    await _storage.save(pet);
  }

  // ---------- БАЗОВЫЕ ДЕЙСТВИЯ ----------

  Future<Pet> feed() async {
    return _applyDelta(satiety: PetRules.feedSatiety, mood: PetRules.feedMood);
  }

  Future<Pet> play() async {
    return _applyDelta(mood: PetRules.playMood, satiety: PetRules.playSatiety);
  }

  Future<Pet> care() async {
    return _applyDelta(care: PetRules.careClean, mood: PetRules.careMood);
  }

  // ---------- ЭФФЕКТЫ ОТ ПОКУПОК ----------

  /// Единая точка входа от PurchaseManager (Алёна).
  Future<Pet> applyEffect(String field, int delta) async {
    switch (field) {
      case 'mood':
        return _applyDelta(mood: delta);
      case 'satiety':
        return _applyDelta(satiety: delta);
      case 'care':
        return _applyDelta(care: delta);
      default:
        throw PetException('Неизвестное поле эффекта: $field');
    }
  }

  /// Применение списка эффектов от заданий.
  Future<Pet> applyConsequences(List<Map<String, dynamic>> consequences) async {
    var pet = _requirePet();
    for (final c in consequences) {
      final field = c['field'] as String;
      final delta = c['delta'] as int;
      pet = _applyDeltaTo(pet, field: field, delta: delta);
    }
    _pet = pet;
    await _storage.save(pet);
    return pet;
  }

  // ---------- РОСТ ----------

  Future<Pet> addGrowthPoints(int points) async {
    if (points < 0) {
      throw PetException('growthPoints не могут уменьшаться');
    }
    var pet = _requirePet();
    final newPoints = pet.growthPoints + points;
    final newStage = _calculateStage(newPoints);
    pet = pet.copyWith(growthPoints: newPoints, growthStage: newStage);
    _pet = pet;
    await _storage.save(pet);
    return pet;
  }

  GrowthStage updateGrowthStage() {
    final pet = _requirePet();
    final stage = _calculateStage(pet.growthPoints);
    if (stage != pet.growthStage) {
      _pet = pet.copyWith(growthStage: stage);
    }
    return stage;
  }

  GrowthStage _calculateStage(int points) {
    if (points >= PetRules.adultThreshold) return GrowthStage.adult;
    if (points >= PetRules.teenThreshold) return GrowthStage.teen;
    return GrowthStage.baby;
  }

  // ---------- СБРОС ----------

  Future<void> resetPet() async {
    _pet = null;
    await _storage.clear();
  }

  // ---------- ВНУТРЕННЕЕ ----------

  Pet _requirePet() {
    final pet = _pet;
    if (pet == null) {
      throw PetException('Питомец не создан. Вызови createPet или loadPet');
    }
    return pet;
  }

  Future<Pet> _applyDelta({
    int mood = 0,
    int satiety = 0,
    int care = 0,
  }) async {
    var pet = _requirePet();
    pet = pet.copyWith(
      mood: PetRules.clamp(pet.mood + mood),
      satiety: PetRules.clamp(pet.satiety + satiety),
      care: PetRules.clamp(pet.care + care),
    );
    _pet = pet;
    await _storage.save(pet);
    return pet;
  }

  Pet _applyDeltaTo(Pet pet, {required String field, required int delta}) {
    switch (field) {
      case 'mood':
        return pet.copyWith(mood: PetRules.clamp(pet.mood + delta));
      case 'satiety':
        return pet.copyWith(satiety: PetRules.clamp(pet.satiety + delta));
      case 'care':
        return pet.copyWith(care: PetRules.clamp(pet.care + delta));
      default:
        throw PetException('Неизвестное поле: $field');
    }
  }
}