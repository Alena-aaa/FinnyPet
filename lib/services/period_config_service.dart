import '../data/period_configs.dart';
import '../models/game_period.dart';
import '../models/period_config.dart';

class PeriodConfigService {
  PeriodConfig getConfig(int periodNumber) {
    return periodConfigs.firstWhere(
        (config) => config.number == periodNumber,
    );
  }
  GamePeriod createPeriod(int periodNumber) {
    final config = getConfig(periodNumber);

    return GamePeriod(
        number: config.number,
        income: config.income,
    );
  }
}