import 'budget_plan.dart';

class GamePeriod {
  final int number;
  final int income;

  BudgetPlan? budgetPlan;

  int actualMandatory;
  int actualOptional;
  int actualSavings;

  bool completed;

  GamePeriod({
    required this.number,
    required this.income,
    this.budgetPlan,
    this.actualMandatory = 0,
    this.actualOptional = 0,
    this.actualSavings = 0,
    this.completed = false,
  });
}