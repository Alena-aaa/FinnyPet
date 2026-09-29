import '../models/transaction.dart';

class TransactionHistory {
  final List<Transaction> transactions = [];

  void add(Transaction transaction) {
    transactions.add(transaction);
  }

  List<Transaction> getByPeriod(int period) {
    return transactions
        .where((transaction)=>transaction.period==period)
        .toList();
  }
}

