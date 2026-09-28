import '../pet/pet.dart';
import '../pet/pet_rules.dart';

/// Модуль роста питомца.
///
/// Отвечает за:
/// - определение стадии по growthPoints
/// - сколько очков нужно до следующей стадии
/// - прогресс до следующей стадии (0..1)
///
/// NOTE: shouldAwardGrowthPoint будет добавлен позже,
/// когда Алёна закончит PeriodManager (нужен класс PeriodResult).
class GrowthManager {
  /// Стадия по количеству очков.
  GrowthStage calculateStage(int growthPoints) {
    if (growthPoints >= PetRules.adultThreshold) return GrowthStage.adult;
    if (growthPoints >= PetRules.teenThreshold) return GrowthStage.teen;
    return GrowthStage.baby;
  }

  /// Сколько очков нужно до следующей стадии.
  /// Возвращает null, если питомец уже adult.
  int? nextStageThreshold(int growthPoints) {
    if (growthPoints < PetRules.teenThreshold) {
      return PetRules.teenThreshold;
    }
    if (growthPoints < PetRules.adultThreshold) {
      return PetRules.adultThreshold;
    }
    return null; // уже adult
  }

  /// Прогресс до следующей стадии (0..1).
  /// Если adult — возвращает 1.0.
  double progressToNextStage(int growthPoints) {
    if (growthPoints >= PetRules.adultThreshold) return 1.0;

    if (growthPoints < PetRules.teenThreshold) {
      // baby → teen: от 0 до teenThreshold
      return (growthPoints / PetRules.teenThreshold).clamp(0.0, 1.0);
    }

    // teen → adult: от teenThreshold до adultThreshold
    final from = PetRules.teenThreshold;
    final to = PetRules.adultThreshold;
    return ((growthPoints - from) / (to - from)).clamp(0.0, 1.0);
  }
}