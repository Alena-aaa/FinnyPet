import 'package:flutter/material.dart';

import '../../app_controller.dart';
import '../../game/pet/pet.dart';
import '../../game/tasks/task.dart';

import 'pet_creation_screen.dart';
import 'how_to_play_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _unlocked = false;

  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _showParentBarrier() {
    int first = 3;
    int second = 4;

    _answerController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Для родителей'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Чтобы открыть родительский раздел, решите пример:',
              ),
              const SizedBox(height: 12),
              Text(
                '$first + $second = ?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ответ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_answerController.text.trim() == '7') {
                  Navigator.pop(context);

                  setState(() {
                    _unlocked = true;
                  });
                } else {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Попробуйте ещё раз'),
                    ),
                  );
                }
              },
              child: const Text('Открыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Раздел для родителей',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Здесь можно посмотреть общий прогресс ребёнка '
                      'и управлять демо-профилем.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _showParentBarrier,
                  child: const Text('Войти'),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HowToPlayScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Как играть?'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _buildParentScreen();
  }

  Widget _buildParentScreen() {
    final controller = AppController.instance;
    final tasks = controller.taskManager.getAllTasks();

    final completedTasks =
        tasks.where((task) => task.completed).length;

    final completedPeriods =
        controller.completedPeriodFacts.length;

    final budgetTasks = _completedTasksForTheme(
      tasks,
      TaskTheme.BUDGET,
    );

    final savingsTasks = _completedTasksForTheme(
      tasks,
      TaskTheme.SAVINGS,
    );

    final purchaseTasks = _completedTasksForTheme(
      tasks,
      TaskTheme.PURCHASE,
    );

    final pet = controller.petManager.getPet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Для родителей'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Общий прогресс'),

          _buildProgressCard(
            icon: Icons.calendar_month,
            title: 'Игровые периоды',
            value: '$completedPeriods / 5',
            progress: completedPeriods / 5,
          ),

          _buildProgressCard(
            icon: Icons.task_alt,
            title: 'Финансовые задания',
            value: '$completedTasks / 6',
            progress: completedTasks / 6,
          ),

          _buildPetCard(pet),

          const SizedBox(height: 24),

          _buildSectionTitle('Пройденные темы'),

          _buildTopicRow(
            title: 'Бюджет',
            completed: budgetTasks,
            total: 2,
            icon: Icons.account_balance_wallet_outlined,
          ),

          _buildTopicRow(
            title: 'Накопления',
            completed: savingsTasks,
            total: 2,
            icon: Icons.savings_outlined,
          ),

          _buildTopicRow(
            title: 'Покупки и платежи',
            completed: purchaseTasks,
            total: 2,
            icon: Icons.shopping_cart_outlined,
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Цели'),

          ...controller.savingsGoals.map(
                (goal) => _buildGoalCard(
              goal.name,
              goal.savedAmount,
              goal.targetAmount,
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Демо-профиль'),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.restart_alt,
                color: Colors.red,
              ),
              title: const Text('Сбросить прогресс'),
              subtitle: const Text(
                'Начать демо заново с первого периода',
              ),
              onTap: _confirmReset,
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _unlocked = false;
                });
              },
              child: const Text('Закрыть родительский раздел'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required String value,
    required double progress,
  }) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: safeProgress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard(Pet? pet) {
    final stage = pet?.growthStage ?? GrowthStage.baby;

    String stageName;

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

    return Card(
      child: ListTile(
        leading: const Icon(Icons.pets),
        title: const Text('Развитие питомца'),
        subtitle: Text('Текущая стадия: $stageName'),
      ),
    );
  }

  Widget _buildTopicRow({
    required String title,
    required int completed,
    required int total,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          '$completed / $total',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(
      String name,
      int saved,
      int target,
      ) {
    final progress = target == 0
        ? 0.0
        : (saved / target).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text('$saved / $target'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
            ),
          ],
        ),
      ),
    );
  }

  int _completedTasksForTheme(
      List<Task> tasks,
      TaskTheme theme,
      ) {
    return tasks
        .where(
          (task) =>
      task.theme == theme &&
          task.completed,
    )
        .length;
  }

  Future<void> _confirmReset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Сбросить прогресс?'),
          content: const Text(
            'Все выполненные задания, накопления и '
                'результаты периодов будут удалены. '
                'Демо начнётся заново.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Сбросить'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) return;

    await AppController.instance.resetDemoProfile();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const PetCreationScreen(),
      ),
          (route) => false,
    );
  }
}