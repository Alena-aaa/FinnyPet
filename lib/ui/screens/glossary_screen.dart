import 'package:flutter/material.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  static const List<Map<String, String>> terms = [
    {
      'term': 'Доход',
      'description': 'Монеты, которые ты получаешь за новый период или за выполнение некоторых заданий.',
    },
    {
      'term': 'Расход',
      'description': 'Монеты, которые ты тратишь на обязательные покупки и желания.',
    },
    {
      'term': 'Обязательные расходы',
      'description': 'Покупки, которые нужны питомцу и которые важно учитывать в бюджете.',
    },
    {
      'term': 'Желания',
      'description': 'Покупки, которые делают жизнь питомца приятнее, но без которых можно обойтись.',
    },
    {
      'term': 'Накопления',
      'description': 'Монеты, которые ты откладываешь на большую цель вместо того, чтобы потратить их сейчас.',
    },
    {
      'term': 'Бюджет',
      'description': 'План того, как ты собираешься распределить свои монеты.',
    },
    {
      'term': 'Баланс',
      'description': 'Количество монет, которые сейчас доступны для трат.',
    },
    {
      'term': 'Финансовая цель',
      'description': 'То, на что ты постепенно копишь монеты.',
    },
    {
      'term': 'План и факт',
      'description': 'Сравнение того, сколько ты собирался потратить, с тем, сколько потратил на самом деле.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Глоссарий'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: terms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = terms[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['term']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['description']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}