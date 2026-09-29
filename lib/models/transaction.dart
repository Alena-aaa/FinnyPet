enum TransactionType{
  income,
  mandatory,
  optional,
  saving,
}

class Transaction { //что произошло, сколько деняк, откуда и куда, в какой период и когда
  final TransactionType type;
  final int amount;
  final String source;
  final int period;
  final DateTime timestamp;

  Transaction ({
    required this.type,
    required this.amount,
    required this.source,
    required this.period,
    required this.timestamp,
});
}

