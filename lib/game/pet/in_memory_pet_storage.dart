import 'pet.dart';
import 'pet_storage.dart';

/// Простая реализация в памяти. Используется для тестов,
/// пока не подключена SQLite.
class InMemoryPetStorage implements PetStorage {
  Pet? _pet;

  @override
  Future<Pet?> load() async => _pet;

  @override
  Future<void> save(Pet pet) async => _pet = pet;

  @override
  Future<void> clear() async => _pet = null;
}