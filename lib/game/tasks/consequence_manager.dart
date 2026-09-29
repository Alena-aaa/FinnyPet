import '../../models/player.dart';
import '../../models/savings_goal.dart';
import '../../services/economy_service.dart';
import '../../models/transaction.dart';
import '../pet/pet_manager.dart';
import 'task.dart';

class AppliedChange {
  final ConsequenceTarget target;
  final String field;
  final int delta;

  const AppliedChange({
    required this.target,
    required this.field,
    required this.delta,
  });

  @override
  String toString() => '${target.name}.$field: $delta';
}

class ConsequenceReport {
  final List<AppliedChange> applied;
  final List<AppliedChange> pending;
  final List<Transaction> transactions;

  const ConsequenceReport({
    required this.applied,
    required this.pending,
    required this.transactions,
  });
}

class ConsequenceManager {
  final PetManager petManager;
  final EconomyService economyService;
  final Player player;
  final SavingsGoal Function() getSavingsGoal;

  ConsequenceManager({
    required this.petManager,
    required this.economyService,
    required this.player,
    required this.getSavingsGoal,
  });

  Future<ConsequenceReport> apply(
      List<Consequence> consequences,
      ) async {
    final applied = <AppliedChange>[];
    final pending = <AppliedChange>[];
    final transactions = <Transaction>[];

    final petConsequences = <Map<String, dynamic>>[];

    for (final c in consequences) {
      switch (c.target) {
        case ConsequenceTarget.PET:
          petConsequences.add({
            'field': c.field,
            'delta': c.delta,
          });
          break;

        case ConsequenceTarget.ECONOMY:
          final success = _applyEconomyChange(c);

          if (success) {
            applied.add(
              AppliedChange(
                target: c.target,
                field: c.field,
                delta: c.delta,
              ),
            );

            final transactionType = c.transactionType;

            if (transactionType != null && c.delta != 0) {
              transactions.add(
                Transaction(
                  type: transactionType,
                  amount: c.delta.abs(),
                  source: c.field,
                  period: player.currentPeriod,
                  timestamp: DateTime.now(),
                ),
              );
            }
          } else {
            pending.add(
              AppliedChange(
                target: c.target,
                field: c.field,
                delta: c.delta,
              ),
            );
          }
          break;
      }
    }

    if (petConsequences.isNotEmpty) {
      await petManager.applyConsequences(petConsequences);

      for (final consequence in petConsequences) {
        applied.add(
          AppliedChange(
            target: ConsequenceTarget.PET,
            field: consequence['field'] as String,
            delta: consequence['delta'] as int,
          ),
        );
      }
    }

    return ConsequenceReport(
      applied: applied,
      pending: pending,
        transactions: transactions,
    );
  }

  bool _applyEconomyChange(Consequence consequence) {

    final savingsGoal = getSavingsGoal();

    switch (consequence.field) {
      case 'balance':
        if (consequence.delta < 0) {
          return economyService.spendMoney(
            player,
            -consequence.delta,
          );
        }

        if (consequence.delta > 0) {
          return economyService.addMoney(
            player,
            consequence.delta,
          );
        }

        return true;

      case 'savings':
        if (consequence.delta > 0) {
          return economyService.saveMoney(
            player,
            savingsGoal,
            consequence.delta,
          );
        }

        if (consequence.delta < 0) {
          final amount = -consequence.delta;

          if (savingsGoal.savedAmount < amount) {
            return false;
          }

          savingsGoal.savedAmount -= amount;
          player.currentBalance += amount;

          return true;
        }

        return true;

      default:
        return false;
    }
  }
}