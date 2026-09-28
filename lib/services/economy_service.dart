import '../models/player.dart';
import '../models/budget_plan.dart';
import '../models/savings_goal.dart';
import '../models/transaction.dart';

class EconomyService{ //начисление денег, трата денег, запрет тратить больше имеющихся денег,
                      // проверка canAfford, гарантия, что баалнс не станет отрицательным
    bool canAfford(Player player, int amount) {
      return player.currentBalance>=amount; //проверяет, может ли игрок себе это позволить
    }

    bool spendMoney(Player player, int amount){ //трата деняк

      if (amount<=0 || !canAfford(player, amount)) { //проверяем, хваатет ли деняк
        return false;
      }
      player.currentBalance -= amount; //тратим
      return true;
    }

    bool addMoney(Player player, int amount) {
      if (amount<=0) {return false;} //чтоб никто -500 не ввел
      player.currentBalance +=amount;
      return true;
    }

    Transaction? createExpenseTransaction({ //баланс пока не меняется, создается только запись
      required TransactionType type,
      required int amount,
      required String source,
      required int period,
    }) {
      if (amount<=0) {
        return null;
      }
      return Transaction(
          type: type,
          amount: amount,
          source: source,
          period: period,
          timestamp: DateTime.now(),
      );
    }

    Transaction? spendMoneyWithTransaction({
      required Player player,
      required int amount,
      required TransactionType type,
      required String source,
      required int period,
    }) {
      if (!spendMoney(player, amount)) {
        return null;
      }
      return createExpenseTransaction(
          type: type,
          amount: amount,
          source: source,
          period: period,
      );
    }

    bool isPlanValid(Player player, BudgetPlan plan) {
      final total = plan.mandatory + plan.optional + plan.savings;
      return total<=player.currentBalance;
    }

    bool saveMoney(Player player, SavingsGoal goal, int amount) {
      if (!canAfford(player, amount) || amount <= 0) {return false;}

      player.currentBalance -= amount; //по сути просто из кошелечка в копилочку денежку складываем
      goal.savedAmount += amount;
      return true;
    }

    Transaction? saveMoneyWithTransaction({
      required Player player,
      required SavingsGoal goal,
      required int amount,
      required int period,
    }) {
      if (!saveMoney(player, goal, amount)) {return null;}
      return Transaction(
          type: TransactionType.saving,
          amount: amount,
          source: goal.name,
          period: period,
          timestamp: DateTime.now(),
      );
    }

}

