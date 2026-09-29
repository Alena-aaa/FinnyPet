import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'pet.dart';
import 'pet_storage.dart';

class SharedPreferencesPetStorage implements PetStorage {
  static const _petKey = 'pet';

  @override
  Future<Pet?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_petKey);

    if (json == null) return null;

    final map = jsonDecode(json) as Map<String, dynamic>;
    return Pet.fromMap(map);
  }

  @override
  Future<void> save(Pet pet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _petKey,
      jsonEncode(pet.toMap()),
    );
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_petKey);
  }
}