import 'package:flutter/material.dart';
import '../../game/pet/pet.dart';
import '../../game/pet/pet_rules.dart';

/// Виджет питомца. Только отображение — никакой логики.
/// Получает готовый Pet через параметр.
class PetWidget extends StatelessWidget {
  final Pet pet;

  const PetWidget({super.key, required this.pet});

  // ---------- ВСПОМОГАТЕЛЬНЫЕ ----------

  /// Эмодзи/символ питомца по типу + цвету + стадии.
  /// Пока заглушки — на Этапе 8 заменим на картинки.
  String _petEmoji() {
    String base;
    switch (pet.type) {
      case PetType.cat:
        base = '🐱';
        break;
      case PetType.dog:
        base = '🐶';
        break;
      case PetType.parrot:
        base = '🦜';
        break;
    }

    // Для baby — маленький, для adult — большой.
    // Пока просто добавляем размер через fontSize.
    return base;
  }

  /// Размер эмодзи по стадии роста.
  double _emojiSize() {
    switch (pet.growthStage) {
      case GrowthStage.baby:
        return 60;
      case GrowthStage.teen:
        return 90;
      case GrowthStage.adult:
        return 120;
    }
  }

  /// Цвет питомца — для фона/подложки.
  Color _petColor() {
    switch (pet.color) {
      case PetColor.black:
        return Colors.grey.shade800;
      case PetColor.white:
        return Colors.grey.shade200;
      case PetColor.red:
        return Colors.red.shade400;
    }
  }

  /// Название стадии роста.
  String _stageLabel() {
    switch (pet.growthStage) {
      case GrowthStage.baby:
        return 'Малыш';
      case GrowthStage.teen:
        return 'Подросток';
      case GrowthStage.adult:
        return 'Взрослый';
    }
  }

  /// Прогресс роста 0..1 — сколько до следующей стадии.
  double _growthProgress() {
    if (pet.growthStage == GrowthStage.adult) return 1.0;
    // baby: 0..2 (нужно 3), teen: 3..5 (нужно 6)
    final points = pet.growthPoints;
    if (pet.growthStage == GrowthStage.baby) {
      return (points / PetRules.teenThreshold).clamp(0.0, 1.0);
    }
    // teen
    final from = PetRules.teenThreshold;
    final to = PetRules.adultThreshold;
    return ((points - from) / (to - from)).clamp(0.0, 1.0);
  }

  /// Полоска состояния (mood/satiety/care).
  Widget _statBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Имя питомца
            Text(
              pet.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Кружок с эмодзи на цветном фоне
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: _petColor().withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _petEmoji(),
                style: TextStyle(fontSize: _emojiSize()),
              ),
            ),
            const SizedBox(height: 12),

            // Стадия роста
            Text(
              _stageLabel(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),

            // Прогресс роста
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _growthProgress(),
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
              ),
            ),
            const SizedBox(height: 16),

            // Полоски состояния
            _statBar('😊 Настроение', pet.mood, Colors.orange),
            _statBar('🍖 Сытость', pet.satiety, Colors.brown),
            _statBar('🧼 Уход', pet.care, Colors.blue),
          ],
        ),
      ),
    );
  }
}