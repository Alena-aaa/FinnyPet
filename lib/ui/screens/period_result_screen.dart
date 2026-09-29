import 'package:flutter/material.dart';

import '../../app_controller.dart';

class PeriodResultScreen extends StatelessWidget {
  const PeriodResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;
    final fact = controller.lastPeriodFact;

    if (fact == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Результат периода')),
        body: const Center(
          child: Text('Результат периода пока недоступен.'),
        ),
      );
    }

    final plan = fact.plan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Период завершён'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ты завершил период!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'План и факт',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (plan != null) ...[
                _buildRow(
                  'Обязательные расходы',
                  plan.mandatory,
                  fact.mandatory,
                ),
                _buildRow(
                  'Желания',
                  plan.optional,
                  fact.optional,
                ),
                _buildRow(
                  'Накопления',
                  plan.savings,
                  fact.savings,
                ),
              ],

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text(
                      '🌱',
                      style: TextStyle(fontSize: 30),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '+${controller.lastPeriodGrowthPoints} очков роста',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.moveToNextPeriod();

                    if (!context.mounted) return;

                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Следующий период',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, int plan, int fact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            '$plan → $fact',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}