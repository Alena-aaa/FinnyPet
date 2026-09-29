import '../models/period_fact.dart';

class GrowthService {
  int calculateGrowthPoints(List<PeriodFact> completedPeriodFacts) {
    int points = 0;

    for (final fact in completedPeriodFacts) {
      // 1. Обязательные расходы были сделаны.
      if (fact.mandatory > 0) {
        points++;
      }

      // 2. Фактические расходы не вышли за рамки плана.
      if (_matchesPlan(fact)) {
        points++;
      }

      // 3. В этом периоде были накопления.
      if (fact.savings >= 10) {
        points++;
      }
    }

    return points;
  }

  bool _matchesPlan(PeriodFact fact) {
    final plan = fact.plan;

    if (plan == null) {
      return false;
    }

    return fact.mandatory <= plan.mandatory &&
        fact.optional <= plan.optional &&
        fact.savings <= plan.savings;
  }
}

