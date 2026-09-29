import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_plan.dart';
import '../models/game_period.dart';
import '../models/player.dart';
import '../models/savings_goal.dart';
import '../models/period_fact.dart';
import '../models/transaction.dart';

class LocalStorageService {
  static const _stateKey = 'app_state';

  Future<void> saveState({
    required Player player,
    required List<SavingsGoal> savingsGoals,
    required SavingsGoal? selectedSavingsGoal,
    required List<GamePeriod> periods,
    required Map<int, Set<int>> purchasedItemsByPeriod,
    required List<Transaction> transactions,
    required List<Transaction> currentPeriodTransactions,
    required List<PeriodFact> completedPeriodFacts,
    required PeriodFact? lastPeriodFact,
    required int lastPeriodGrowthPoints,
    required List<Map<String, dynamic>> taskStates,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'player': {
        'id': player.id,
        'name': player.name,
        'currentBalance': player.currentBalance,
        'currentPeriod': player.currentPeriod,
      },

      'savingsGoals': savingsGoals.map((goal) => {
        'id': goal.id,
        'name': goal.name,
        'targetAmount': goal.targetAmount,
        'savedAmount': goal.savedAmount,
      }).toList(),

      'selectedSavingsGoalId': selectedSavingsGoal?.id,

      'periods': periods.map((period) => {
        'number': period.number,
        'income': period.income,
        'budgetPlan': period.budgetPlan == null
            ? null
            : {
          'mandatory': period.budgetPlan!.mandatory,
          'optional': period.budgetPlan!.optional,
          'savings': period.budgetPlan!.savings,
        },
        'actualMandatory': period.actualMandatory,
        'actualOptional': period.actualOptional,
        'actualSavings': period.actualSavings,
        'completed': period.completed,
      }).toList(),

      'purchasedItemsByPeriod': purchasedItemsByPeriod.map(
            (key, value) => MapEntry(
          key.toString(),
          value.toList(),
        ),
      ),

      'transactions': transactions.map(_transactionToMap).toList(),

      'currentPeriodTransactions':
      currentPeriodTransactions.map(_transactionToMap).toList(),

      'completedPeriodFacts':
      completedPeriodFacts.map(_periodFactToMap).toList(),

      'lastPeriodFact':
      lastPeriodFact == null ? null : _periodFactToMap(lastPeriodFact),

      'lastPeriodGrowthPoints': lastPeriodGrowthPoints,

      'taskStates': taskStates,
    };

    await prefs.setString(_stateKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_stateKey);

    if (json == null) return null;

    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stateKey);
  }

  Map<String, dynamic> _transactionToMap(Transaction transaction) {
    return {
      'type': transaction.type.name,
      'amount': transaction.amount,
      'source': transaction.source,
      'period': transaction.period,
      'timestamp': transaction.timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> _periodFactToMap(PeriodFact fact) {
    return {
      'mandatory': fact.mandatory,
      'optional': fact.optional,
      'savings': fact.savings,
      'plan': fact.plan == null
          ? null
          : {
        'mandatory': fact.plan!.mandatory,
        'optional': fact.plan!.optional,
        'savings': fact.plan!.savings,
      },
    };
  }

  BudgetPlan? _budgetPlanFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;

    return BudgetPlan(
      mandatory: map['mandatory'] as int,
      optional: map['optional'] as int,
      savings: map['savings'] as int,
    );
  }
}