import 'package:flutter/material.dart';
import '../../app_controller.dart';
import '../../models/savings_goal.dart';
import '../../game/pet/pet.dart';
import 'glossary_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppController.instance;
    final pet = controller.petManager;
    final completedPeriods = controller.completedPeriodFacts.length;
    final completedTasks = controller.taskManager.getAllTasks()
        .where((task) => task.completed)
        .length;

    final currentPet = pet.getPet();
    final growthPoints = currentPet?.growthPoints ?? 0;
    final growthStage = currentPet?.growthStage ?? GrowthStage.baby;

    return Scaffold(
      backgroundColor: const Color(0xFFABE2E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6B68),
        title: const Text(
          'Прогресс и статистика',
          style: TextStyle(
            fontFamily: 'Handjet',
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPetProgress(
              growthStage,
              growthPoints,
            ),
            const SizedBox(height: 16),

            _buildGeneralProgress(
              completedPeriods,
              completedTasks,
            ),
            const SizedBox(height: 16),

            _buildGoals(controller.savingsGoals),
            const SizedBox(height: 16),

            _buildLastPeriod(controller),
            const SizedBox(height: 16),
            _buildHistory(controller),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GlossaryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book),
                label: const Text(
                  'Глоссарий',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6B68),
                  foregroundColor: const Color(0xFFD9D9D9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetProgress(
      GrowthStage stage,
      int growthPoints,
      ) {
    final String stageName;

    switch (stage) {
      case GrowthStage.baby:
        stageName = 'Малыш';
        break;
      case GrowthStage.teen:
        stageName = 'Подросток';
        break;
      case GrowthStage.adult:
        stageName = 'Взрослый';
        break;
    }

    final progress = (growthPoints / 6).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F6B68),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Развитие питомца',
            style: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 22,
              fontFamily: 'Handjet',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Стадия: $stageName',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Очки роста: $growthPoints',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: const Color(0xFF28CDCA),
            backgroundColor: const Color(0xFFD9D9D9),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralProgress(
      int completedPeriods,
      int completedTasks,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4EA6A2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Обучение',
            style: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 22,
              fontFamily: 'Handjet',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Периоды: $completedPeriods / 5',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Задания: $completedTasks / 6',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoals(List<SavingsGoal> goals) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4EA6A2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Цели',
            style: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 22,
              fontFamily: 'Handjet',
            ),
          ),
          const SizedBox(height: 12),
          for (final goal in goals) ...[
            Text(
              goal.name,
              style: const TextStyle(
                color: Color(0xFFD9D9D9),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${goal.savedAmount} / ${goal.targetAmount}',
              style: const TextStyle(
                color: Color(0xFFD9D9D9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: goal.targetAmount == 0
                  ? 0
                  : (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0),
              minHeight: 8,
              color: const Color(0xFF28CDCA),
              backgroundColor: const Color(0xFF2F6B68),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildLastPeriod(AppController controller) {
    final fact = controller.lastPeriodFact;

    if (fact == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF4EA6A2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Последний период ещё не завершён.',
          style: TextStyle(
            color: Color(0xFFD9D9D9),
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4EA6A2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Последний период',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 22,
              fontFamily: 'Handjet',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Обязательные: ${fact.mandatory}',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 17,
            ),
          ),
          Text(
            'Желания: ${fact.optional}',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 17,
            ),
          ),
          Text(
            'Накопления: ${fact.savings}',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+${controller.lastPeriodGrowthPoints} очков роста',
            style: const TextStyle(
              color: Color(0xFF28CDCA),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(AppController controller) {
    if (controller.completedPeriodFacts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF4EA6A2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'История пока пуста.',
          style: TextStyle(
            color: Color(0xFFD9D9D9),
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4EA6A2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'История периодов',
            style: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 22,
              fontFamily: 'Handjet',
            ),
          ),
          const SizedBox(height: 12),

          for (int i = 0;
          i < controller.completedPeriodFacts.length;
          i++) ...[
            Text(
              'Период ${i + 1}',
              style: const TextStyle(
                color: Color(0xFFD9D9D9),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Обязательные: ${controller.completedPeriodFacts[i].mandatory}',
              style: const TextStyle(
                color: Color(0xFFD9D9D9),
                fontSize: 16,
              ),
            ),
            Text(
              'Желания: ${controller.completedPeriodFacts[i].optional}',
              style: const TextStyle(
                color: Color(0xFFD9D9D9),
                fontSize: 16,
              ),
            ),
            Text(
              'Накопления: ${controller.completedPeriodFacts[i].savings}',
              style: const TextStyle(
                color: Color(0xFFD9D9D9),
                fontSize: 16,
              ),
            ),
            if (i < controller.completedPeriodFacts.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  color: Color(0xFFD9D9D9),
                ),
              ),
          ],
        ],
      ),
    );
  }
}