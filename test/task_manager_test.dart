
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_finance/game/pet/pet.dart';
import 'package:pet_finance/game/pet/pet_manager.dart';
import 'package:pet_finance/game/pet/in_memory_pet_storage.dart';
import 'package:pet_finance/game/tasks/task.dart';
import 'package:pet_finance/game/tasks/task_manager.dart';
import 'package:pet_finance/game/tasks/consequence_manager.dart';
import 'package:pet_finance/models/player.dart';
import 'package:pet_finance/models/savings_goal.dart';
import 'package:pet_finance/services/economy_service.dart';

void main() {
  late PetManager petManager;
  late ConsequenceManager consequenceManager;
  late TaskManager taskManager;
  late Player player;
  late SavingsGoal savingsGoal;

  setUp(() async {
    petManager = PetManager(
      storage: InMemoryPetStorage(),
    );

    player = Player(
      id: 'player_1',
      name: 'Player',
      currentBalance: 100,
      currentPeriod: 1,
    );

    savingsGoal = SavingsGoal(
      id: 'goal_1',
      name: 'Домик для питомца',
      targetAmount: 100,
      savedAmount: 0,
    );

    consequenceManager = ConsequenceManager(
      petManager: petManager,
      economyService: EconomyService(),
      player: player,
      getSavingsGoal: () => savingsGoal,
    );

    taskManager = TaskManager(
      consequenceManager: consequenceManager,
    );

    await petManager.createPet(
      id: '1',
      type: PetType.cat,
      color: PetColor.red,
      name: 'Барсик',
    );
  });

  // ---------- ВЫДАЧА ЗАДАНИЙ ----------

  test('всего 6 заданий', () {
    expect(taskManager.getAllTasks().length, 6);
  });

  test('2 задания BUDGET', () {
    final budget = taskManager
        .getAllTasks()
        .where((t) => t.theme == TaskTheme.BUDGET)
        .toList();

    expect(budget.length, 2);
  });

  test('2 задания SAVINGS', () {
    final savings = taskManager
        .getAllTasks()
        .where((t) => t.theme == TaskTheme.SAVINGS)
        .toList();

    expect(savings.length, 2);
  });

  test('2 задания PURCHASE', () {
    final purchase = taskManager
        .getAllTasks()
        .where((t) => t.theme == TaskTheme.PURCHASE)
        .toList();

    expect(purchase.length, 2);
  });

  test('getTaskForPeriod(1) возвращает задание периода 1', () {
    final task = taskManager.getTaskForPeriod(1);

    expect(task, isNotNull);
    expect(task!.periodNumber, 1);
  });

  test('getTaskById находит задание', () {
    final task = taskManager.getTaskById('budget_1');

    expect(task, isNotNull);
    expect(task!.theme, TaskTheme.BUDGET);
  });

  test('getTaskById не находит несуществующее', () {
    final task = taskManager.getTaskById('no_such_task');

    expect(task, isNull);
  });

  // ---------- ВЫБОР ----------

  test('submitChoice применяет PET-последствия', () async {
    final before = petManager.getPet()!;
    final beforeSatiety = before.satiety;

    // budget_1, choice 'a': satiety +20, mood -5
    final result = await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'a',
    );

    expect(result.success, isTrue);
    expect(result.explanation, isNotNull);

    final after = petManager.getPet()!;

    expect(after.satiety, beforeSatiety + 20);
  });

  test('submitChoice применяет ECONOMY-последствия', () async {
    // budget_1, choice 'a': balance -30
    expect(player.currentBalance, 100);

    final result = await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'a',
    );

    expect(result.success, isTrue);
    expect(player.currentBalance, 70);
  });

  test('submitChoice добавляет применённую экономику в report', () async {
    final result = await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'a',
    );

    expect(result.report, isNotNull);
    expect(result.report!.pending, isEmpty);

    final balanceChange = result.report!.applied.firstWhere(
      (change) => change.field == 'balance',
    );

    expect(balanceChange.delta, -30);
  });

  test('submitChoice помечает задание completed', () async {
    expect(taskManager.isTaskCompleted('budget_1'), isFalse);

    await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'a',
    );

    expect(taskManager.isTaskCompleted('budget_1'), isTrue);
  });

  test('submitChoice сохраняет chosenChoiceId', () async {
    await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'b',
    );

    final task = taskManager.getTaskById('budget_1');

    expect(task!.chosenChoiceId, 'b');
  });

  test('submitChoice падает на несуществующем задании', () async {
    final result = await taskManager.submitChoice(
      taskId: 'no_such_task',
      choiceId: 'a',
    );

    expect(result.success, isFalse);
    expect(result.errorMessage, isNotNull);
  });

  test('submitChoice падает на несуществующем выборе', () async {
    final result = await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'no_such_choice',
    );

    expect(result.success, isFalse);
    expect(result.errorMessage, isNotNull);
  });

  test('повторный submitChoice падает — задание уже выполнено', () async {
    await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'a',
    );

    final second = await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'b',
    );

    expect(second.success, isFalse);
    expect(second.errorMessage, contains('выполнено'));
  });

  // ---------- НАКОПЛЕНИЯ ----------

  test('submitChoice применяет изменение накоплений', () async {
    // savings_1, choice 'a':
    // savings +30, balance -30
    expect(player.currentBalance, 100);
    expect(savingsGoal.savedAmount, 0);

    final result = await taskManager.submitChoice(
      taskId: 'savings_1',
      choiceId: 'a',
    );

    expect(result.success, isTrue);
    expect(player.currentBalance, 70);
    expect(savingsGoal.savedAmount, 30);
  });

  // ---------- СБРОС ----------

  test('resetTask возвращает задание в исходное', () async {
    await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'a',
    );

    expect(taskManager.isTaskCompleted('budget_1'), isTrue);

    taskManager.resetTask('budget_1');

    expect(taskManager.isTaskCompleted('budget_1'), isFalse);

    final task = taskManager.getTaskById('budget_1');

    expect(task!.chosenChoiceId, isNull);
  });

  test('resetAll сбрасывает все задания', () async {
    await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'a',
    );

    await taskManager.submitChoice(
      taskId: 'savings_1',
      choiceId: 'a',
    );

    taskManager.resetAll();

    expect(taskManager.isTaskCompleted('budget_1'), isFalse);
    expect(taskManager.isTaskCompleted('savings_1'), isFalse);
  });

  // ---------- ПЕРИОДЫ ----------

  test(
    'после выполнения задания периода 1 getTaskForPeriod(1) возвращает null',
    () async {
      await taskManager.submitChoice(
        taskId: 'budget_1',
        choiceId: 'a',
      );

      final task = taskManager.getTaskForPeriod(1);

      expect(task, isNull);
    },
  );
}
