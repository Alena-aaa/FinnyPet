import '../models/period_config.dart';
import '../models/purchase.dart';

final periodConfigs = [
  PeriodConfig(
    number: 1,
    income: 100,
    purchases: [
      Purchase(
        id: 'p1_food',
        name: 'Еда',
        price: 30,
        category: PurchaseCategory.mandatory,
        period: 1,
      ),
      Purchase(
        id: 'p1_toy',
        name: 'Игрушка',
        price: 20,
        category: PurchaseCategory.optional,
        period: 1,
      ),
      Purchase(
        id: 'p1_icecream',
        name: 'Мороженое',
        price: 10,
        category: PurchaseCategory.optional,
        period: 1,
      ),
    ],
  ),
  PeriodConfig(
    number: 2,
    income: 120,
    purchases: [
      Purchase(
        id: 'p2_food',
        name: 'Еда',
        price: 35,
        category: PurchaseCategory.mandatory,
        period: 2,
      ),
      Purchase(
        id: 'p2_toy',
        name: 'Игрушка',
        price: 25,
        category: PurchaseCategory.optional,
        period: 2,
      ),
      Purchase(
        id: 'p2_treat',
        name: 'Лакомство',
        price: 15,
        category: PurchaseCategory.optional,
        period: 2,
      ),
    ],
  ),
  PeriodConfig(
    number: 3,
    income: 130,
    purchases: [
      Purchase(
        id: 'p3_food',
        name: 'Еда',
        price: 40,
        category: PurchaseCategory.mandatory,
        period: 3,
      ),
      Purchase(
        id: 'p3_toy',
        name: 'Игрушка',
        price: 30,
        category: PurchaseCategory.optional,
        period: 3,
      ),
      Purchase(
        id: 'p3_treat',
        name: 'Лакомство',
        price: 20,
        category: PurchaseCategory.optional,
        period: 3,
      ),
    ],
  ),
  PeriodConfig(
    number: 4,
    income: 140,
    purchases: [
      Purchase(
        id: 'p4_food',
        name: 'Еда',
        price: 45,
        category: PurchaseCategory.mandatory,
        period: 4,
      ),
      Purchase(
        id: 'p4_toy',
        name: 'Игрушка',
        price: 30,
        category: PurchaseCategory.optional,
        period: 4,
      ),
      Purchase(
        id: 'p4_treat',
        name: 'Лакомство',
        price: 20,
        category: PurchaseCategory.optional,
        period: 4,
      ),
    ],
  ),
  PeriodConfig(
    number: 5,
    income: 150,
    purchases: [
      Purchase(
        id: 'p5_food',
        name: 'Еда',
        price: 50,
        category: PurchaseCategory.mandatory,
        period: 5,
      ),
      Purchase(
        id: 'p5_toy',
        name: 'Игрушка',
        price: 35,
        category: PurchaseCategory.optional,
        period: 5,
      ),
      Purchase(
        id: 'p5_treat',
        name: 'Лакомство',
        price: 25,
        category: PurchaseCategory.optional,
        period: 5,
      ),
    ],
  ),
];

