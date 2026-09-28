import '../models/player.dart';
import '../models/purchase.dart';
import '../models/transaction.dart';
import 'economy_service.dart';

class PurchaseService {
  final EconomyService economyService;

  PurchaseService({EconomyService? economyService})
      : economyService = economyService??EconomyService();

  Transaction? buyPurchase({
    required Player player,
    required Purchase purchase,
}) {
    final transactionType = purchase.category == PurchaseCategory.mandatory
        ?TransactionType.mandatory: TransactionType.optional;

    return economyService.spendMoneyWithTransaction(
        player: player,
        amount: purchase.price,
        type: transactionType,
        source: purchase.name,
        period: purchase.period,
    );

  }
}