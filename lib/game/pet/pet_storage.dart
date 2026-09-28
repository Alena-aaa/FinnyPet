import 'pet.dart';

/// Абстракция хранилища. Реализация — общая SQLite (договориться с командой).
abstract class PetStorage {
  Future<Pet?> load();
  Future<void> save(Pet pet);
  Future<void> clear();
}