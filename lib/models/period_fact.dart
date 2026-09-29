import 'budget_plan.dart';

class PeriodFact {
  final int mandatory;
  final int optional;
  final int savings;
  final BudgetPlan? plan;

  PeriodFact({
    required this.mandatory,
    required this.optional,
    required this.savings,
    this.plan,
});
}

