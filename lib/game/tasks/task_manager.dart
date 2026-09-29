import 'task.dart';
import 'task_data.dart';
import 'consequence_manager.dart';
import '/../models/transaction.dart';

/// Результат выбора — что показать ребёнку.
class ChoiceResult {
  final bool success;
  final String? errorMessage;
  final String? explanation;
  final ConsequenceReport? report;
  final List<Transaction> transactions;


  const ChoiceResult({
    required this.success,
    this.errorMessage,
    this.explanation,
    this.report,
    this.transactions = const [],
  });
}

/// Движок заданий: выдаёт задания, обрабатывает выборы.
class TaskManager {
  final ConsequenceManager consequenceManager;
  final List<Task> _tasks;

  TaskManager({required this.consequenceManager})
      : _tasks = TaskData.allTasks();

  // ---------- ВЫДАЧА ----------

  /// Все задания.
  List<Task> getAllTasks() => List.unmodifiable(_tasks);

  /// Задание по номеру периода.
  Task? getTaskForPeriod(int periodNumber) {
    for (final t in _tasks) {
      if (t.periodNumber == periodNumber && !t.completed) {
        return t;
      }
    }
    return null;
  }

  bool isCurrentPeriodCompleted(int periodNumber) {
    final periodTasks = _tasks
        .where((task) => task.periodNumber == periodNumber)
        .toList();

    if (periodTasks.isEmpty) {
      return false;
    }

    return periodTasks.every((task) => task.completed);
  }

  /// Задание по id.
  Task? getTaskById(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  // ---------- СОСТОЯНИЕ ----------

  bool isTaskCompleted(String taskId) {
    final task = getTaskById(taskId);
    return task?.completed ?? false;
  }

  // ---------- ВЫБОР ----------

  /// Ребёнок сделал выбор.
  Future<ChoiceResult> submitChoice({
    required String taskId,
    required String choiceId,
  }) async {
    final task = getTaskById(taskId);
    if (task == null) {
      return const ChoiceResult(
        success: false,
        errorMessage: 'Задание не найдено',
      );
    }

    if (task.completed) {
      return const ChoiceResult(
        success: false,
        errorMessage: 'Задание уже выполнено',
      );
    }

    final choice = task.findChoice(choiceId);
    if (choice == null) {
      return const ChoiceResult(
        success: false,
        errorMessage: 'Выбор не найден',
      );
    }

    // Применяем последствия
    final report = await consequenceManager.apply(choice.consequences);

    // Помечаем задание выполненным
    task.completed = true;
    task.chosenChoiceId = choice.id;

    return ChoiceResult(
      success: true,
      explanation: choice.explanation,
      report: report,
      transactions: report.transactions,
    );
  }

  // ---------- СБРОС (для Demo Mode) ----------

  void resetTask(String taskId) {
    final task = getTaskById(taskId);
    if (task == null) return;
    task.completed = false;
    task.chosenChoiceId = null;
  }

  void restoreTaskState(
      List<Map<String, dynamic>> savedStates,
      ) {
    for (final saved in savedStates) {
      final taskId = saved['taskId'] as String;
      final task = getTaskById(taskId);

      if (task == null) continue;

      task.completed = saved['completed'] as bool? ?? false;
      task.chosenChoiceId = saved['chosenChoiceId'] as String?;
    }
  }

  void resetAll() {
    for (final t in _tasks) {
      t.completed = false;
      t.chosenChoiceId = null;
    }
  }
}

