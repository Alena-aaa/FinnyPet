import 'package:flutter/material.dart';

import 'budget_screen.dart';

import '../../app_controller.dart';
import '../../models/transaction.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {

  static const List<String> _itemNames = [
    'Корм',
    'Лекарство',
    'Наполнитель',
    'Средство для ухода',
    'Игрушка',
    'Мячик',
    'Шляпа',
    'Домик',
  ];

  static const List<String> _itemTypes = [
    'Обязательное',
    'Обязательное',
    'Обязательное',
    'Обязательное',
    'Желание',
    'Желание',
    'Желание',
    'Желание',
  ];

  static const int itemPrice = 50;

  final purchasedItems = AppController.instance.purchasedItems;

  Future<void> _buyItem(int index) async {
    final shouldBuy = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isMandatory = _itemTypes[index] == 'Обязательное';

        return AlertDialog(
          title: Text(_itemNames[index]),
          content: Text(
            'Цена: $itemPrice монет\n\n'
                'Тип: ${_itemTypes[index]}\n\n'
                'Эффект на питомца: '
                '${isMandatory ? 'поможет поддерживать хорошее самочувствие' : 'подарит питомцу хорошее настроение'}.\n\n'
                'Купить этот товар?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Купить'),
            ),
          ],
        );
      },
    );

    if (shouldBuy != true) {
      return;
    }

    final player = AppController.instance.player;
    final economyService = AppController.instance.economyService;

    if (purchasedItems.contains(index)) {
      return;
    }

    final success = economyService.spendMoney(
      player,
      itemPrice,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Недостаточно монет'),
        ),
      );
      return;
    }

    AppController.instance.currentPeriodTransactions.add(
      Transaction(
        type: _itemTypes[index] == 'Обязательное'
            ? TransactionType.mandatory
            : TransactionType.optional,
        amount: itemPrice,
        source: _itemNames[index],
        period: player.currentPeriod,
        timestamp: DateTime.now(),
      ),
    );

    setState(() {
      purchasedItems.add(index);
    });

    await AppController.instance.saveState();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Товар ${index + 1} куплен!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;
    final balance = controller.player.currentBalance;
    final currentPeriod = controller.player.currentPeriod;
    final period = controller.periods[currentPeriod - 1];

    if (period.budgetPlan == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFABE2E3),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F6B68),
          title: const Text(
            'Магазин',
            style: TextStyle(
              fontFamily: 'Handjet',
              fontSize: 26,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Сначала составь бюджет на текущий период',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => BudgetScreen(
                          periodNumber: currentPeriod,
                        ),
                      ),
                    );

                    if (result == true && mounted) {
                      setState(() {});
                    }
                  },
                  child: const Text('Составить бюджет'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFABE2E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6B68),
        title: const Text(
          'Магазин',
          style: TextStyle(
            fontFamily: 'Handjet',
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2F6B68),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Монеты: $balance',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD9D9D9),
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: 8,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final isPurchased = purchasedItems.contains(index);

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4EA6A2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2F6B68),
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Color(0xFF2F6B68),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _itemNames[index],
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 20,
                            fontFamily: 'Handjet',
                          ),
                        ),

                        Text(
                          _itemTypes[index],
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F6B68),
                          ),
                          onPressed: isPurchased
                              ? null
                              : () => _buyItem(index),
                          child: Text(
                            isPurchased
                                ? 'Куплено'
                                : 'Купить (50)',
                            style: const TextStyle(
                              color: Color(0xFFD9D9D9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}