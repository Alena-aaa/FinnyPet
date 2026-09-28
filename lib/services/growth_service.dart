import '../models/period_fact.dart';

class GrowthService {
  int calculateGrowthPoints(PeriodFact fact) {
    if (fact.mandatory > 0 && fact.savings >= 10) {
      return 1;
    }

    return 0;
  }
}