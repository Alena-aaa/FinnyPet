import '../models/budget_plan.dart';
import '../models/period_fact.dart';
import '../models/period_result.dart';
import '../models/transaction.dart';
import '../models/game_period.dart';

class PeriodService {
  PeriodFact calculateFact(List<Transaction> transactions,  BudgetPlan? plan,) {
    int mandatory =0;
    int optional =0;
    int savings =0;

    for (final transaction in transactions) {
      switch(transaction.type) {
        case TransactionType.mandatory:
          mandatory+=transaction.amount;
          break;
        case TransactionType.optional:
          optional+=transaction.amount;
          break;
        case TransactionType.saving:
          savings +=transaction.amount;
          break;
        case TransactionType.income:
          break;
      }
    }

    return PeriodFact (
      mandatory: mandatory,
      optional: optional,
      savings: savings,
      plan: plan,
    );
  }

  PeriodResult comparePlanAndFact(
      BudgetPlan plan,
      PeriodFact fact,
      int growthPoints,
      ) {
    return PeriodResult(
      mandatoryDifference: fact.mandatory - plan.mandatory,
      optionalDifference: fact.optional - plan.optional,
      savingsDifference: fact.savings - plan.savings,
      growthPoints: growthPoints,
    );
  }

  bool canCompletePeriod({
    required GamePeriod period,
    required List<Transaction> transactions,
}) {
    if (period.completed) {return false;}
    if (period.budgetPlan==null) {return false;}

    final fact = calculateFact(transactions,  period.budgetPlan,);
    final totalSpent = fact.mandatory+fact.optional+fact.savings;
    return totalSpent<=period.income;
  }

  PeriodResult? completePeriod({
    required GamePeriod period,
    required List<Transaction> transactions,
}) {
    if (!canCompletePeriod(
        period: period,
        transactions: transactions,
    )) {return null;}

    final fact = calculateFact(transactions,  period.budgetPlan,);

    period.actualMandatory = fact.mandatory;
    period.actualOptional = fact.optional;
    period.actualSavings = fact.savings;
    period.completed = true;

    final growthPoints = 0; //!!!

    return comparePlanAndFact(period.budgetPlan!, fact, growthPoints,);
  }
}

