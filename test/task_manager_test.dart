import 'package:flutter_test/flutter_test.dart';
import 'package:pet_budget_app/game/pet/pet.dart';
import 'package:pet_budget_app/game/pet/pet_manager.dart';
import 'package:pet_budget_app/game/pet/in_memory_pet_storage.dart';
import 'package:pet_budget_app/game/tasks/task.dart';
import 'package:pet_budget_app/game/tasks/task_manager.dart';
import 'package:pet_budget_app/game/tasks/consequence_manager.dart';

void main() {
  late PetManager petManager;
  late ConsequenceManager consequenceManager;
  late TaskManager taskManager;

  setUp(() async {
    petManager = PetManager(storage: InMemoryPetStorage());
    consequenceManager = ConsequenceManager(petManager: petManager);
    taskManager = TaskManager(consequenceManager: consequenceManager);

    // Создаём питомца для тестов
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

  test('submitChoice помечает задание completed', () async {
    expect(taskManager.isTaskCompleted('budget_1'), isFalse);

    await taskManager.submitChoice(taskId: 'budget_1', choiceId: 'a');

    expect(taskManager.isTaskCompleted('budget_1'), isTrue);
  });

  test('submitChoice сохраняет chosenChoiceId', () async {
    await taskManager.submitChoice(taskId: 'budget_1', choiceId: 'b');

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
    await taskManager.submitChoice(taskId: 'budget_1', choiceId: 'a');

    final second = await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'b',
    );

    expect(second.success, isFalse);
    expect(second.errorMessage, contains('выполнено'));
  });

  // ---------- ОТЧЁТ ----------

  test('submitChoice возвращает report с ECONOMY в pending', () async {
    // budget_1, choice 'a' содержит ECONOMY balance -30
    final result = await taskManager.submitChoice(
      taskId: 'budget_1',
      choiceId: 'a',
    );

    expect(result.report, isNotNull);
    expect(result.report!.pending.isNotEmpty, isTrue);
  });

  // ---------- СБРОС ----------

  test('resetTask возвращает задание в исходное', () async {
    await taskManager.submitChoice(taskId: 'budget_1', choiceId: 'a');
    expect(taskManager.isTaskCompleted('budget_1'), isTrue);

    taskManager.resetTask('budget_1');
    expect(taskManager.isTaskCompleted('budget_1'), isFalse);

    final task = taskManager.getTaskById('budget_1');
    expect(task!.chosenChoiceId, isNull);
  });

  test('resetAll сбрасывает все задания', () async {
    await taskManager.submitChoice(taskId: 'budget_1', choiceId: 'a');
    await taskManager.submitChoice(taskId: 'savings_1', choiceId: 'a');

    taskManager.resetAll();

    expect(taskManager.isTaskCompleted('budget_1'), isFalse);
    expect(taskManager.isTaskCompleted('savings_1'), isFalse);
  });

  // ---------- ПЕРИОДЫ ----------

  test('после выполнения задания периода 1 getTaskForPeriod(1) возвращает null', () async {
    await taskManager.submitChoice(taskId: 'budget_1', choiceId: 'a');
    final task = taskManager.getTaskForPeriod(1);
    expect(task, isNull);
  });
}