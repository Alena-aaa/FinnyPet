import '../models/player.dart';
import '../models/savings_goal.dart';
import '../models/transaction.dart';
import 'economy_service.dart';

class SavingsService {
  final EconomyService economyService;

  SavingsService({EconomyService? economyService})
      : economyService = economyService??EconomyService();

  Transaction? saveMoney({
    required Player player,
    required SavingsGoal goal,
    required int amount,
    required int period,
}) {
    return economyService.saveMoneyWithTransaction(
        player: player,
        goal: goal,
        amount: amount,
        period: period,
    );
  }
}