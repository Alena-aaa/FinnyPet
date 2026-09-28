/// Единые правила для питомца. Менять только с согласия команды.
class PetRules {
  static const int statMin = 0;
  static const int statMax = 100;

  static const int startMood = 70;
  static const int startSatiety = 70;
  static const int startCare = 70;

  /// Порог для перехода в стадию teen.
  static const int teenThreshold = 3;

  /// Порог для перехода в стадию adult.
  static const int adultThreshold = 6;

  /// Эффекты от действий (пример, согласуй с Алёной).
  static const int feedSatiety = 20;
  static const int feedMood = 5;
  static const int playMood = 15;
  static const int playSatiety = -5;
  static const int careClean = 20;
  static const int careMood = 5;

  /// Клампит значение в допустимый диапазон.
  static int clamp(int value) {
    if (value < statMin) return statMin;
    if (value > statMax) return statMax;
    return value;
  }
}