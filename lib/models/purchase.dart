enum PurchaseCategory {
  mandatory,
  optional,
}

class Purchase {
  final String id;
  final String name;
  final int price;
  final PurchaseCategory category;
  final String? petEffect;
  final int period;

  Purchase({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.petEffect,
    required this.period,
});
}
