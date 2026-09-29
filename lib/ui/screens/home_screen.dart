import 'package:flutter/material.dart';

import '../../app_controller.dart';
import '../widgets/pet_widget.dart';
import 'task_screen.dart';
import 'budget_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final pet = AppController.instance.petManager.getPet();

    if (pet == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFABE2E3),
        body: Center(
          child: Text(
            'Питомец не найден',
            style: TextStyle(
              color: Color(0xFF2F6B68),
              fontSize: 22,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFABE2E3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя панель
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F6B68),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pet.name,
                      style: const TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF28CDCA),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F6B68),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${AppController.instance.player.currentBalance}',
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Питомец
              Center(
                child: PetWidget(pet: pet),
              ),

              const SizedBox(height: 20),

              // Цели
              Builder(
                builder: (context) {
                  final controller = AppController.instance;
                  final goals = controller.savingsGoals;
                  final selectedGoal = controller.currentSavingsGoal;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4EA6A2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Цели:',
                          style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 12),

                        for (final goal in goals) ...[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                controller.selectedSavingsGoal = goal;
                              });
                            },
                            child: _GoalTile(
                              title: goal.name,
                              savedAmount: goal.savedAmount,
                              targetAmount: goal.targetAmount,
                              selected: goal == selectedGoal,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  );
                },
              ),

              // Временная кнопка перехода к заданиям.
              // Потом заменим её нормальным блоком текущего задания.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final controller = AppController.instance;
                    final currentPeriod = controller.player.currentPeriod;
                    final period = controller.periods[currentPeriod - 1];

                    // Сначала составляем бюджет текущего периода.
                    if (period.budgetPlan == null) {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => BudgetScreen(
                            periodNumber: currentPeriod,
                          ),
                        ),
                      );

                      if (!mounted) return;

                      setState(() {});

                      // Если пользователь не подтвердил бюджет,
                      // дальше к заданию не идём.
                      if (result != true) {
                        return;
                      }
                    }

                    final task = controller.taskManager.getTaskForPeriod(
                      currentPeriod,
                    );

                    if (task == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('На этот период заданий больше нет'),
                        ),
                      );
                      return;
                    }

                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TaskScreen(
                          task: task,
                          taskManager: controller.taskManager,
                        ),
                      ),
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6B68),
                    foregroundColor: const Color(0xFFD9D9D9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'ТЕКУЩЕЕ ЗАДАНИЕ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
}

mixin goal {
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.title,
    required this.savedAmount,
    required this.targetAmount,
    required this.selected,
  });

  final String title;
  final int savedAmount;
  final int targetAmount;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final progress = targetAmount == 0
        ? 0.0
        : (savedAmount / targetAmount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2F6B68),
        border: Border.all(
          color: selected
              ? const Color(0xFF28CDCA)
              : const Color(0xFFD9D9D9),
          width: selected ? 4 : 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                '$savedAmount / $targetAmount',
                style: const TextStyle(
                  color: Color(0xFFD9D9D9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF4EA6A2),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF28CDCA),
            ),
          ),
        ],
      ),
    );
  }
}