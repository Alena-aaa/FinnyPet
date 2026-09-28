import 'task.dart';
import 'task_data.dart';
import 'consequence_manager.dart';

/// Результат выбора — что показать ребёнку.
class ChoiceResult {
  final bool success;
  final String? errorMessage;
  final String? explanation;
  final ConsequenceReport? report;

  const ChoiceResult({
    required this.success,
    this.errorMessage,
    this.explanation,
    this.report,
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
    );
  }

  // ---------- СБРОС (для Demo Mode) ----------

  void resetTask(String taskId) {
    final task = getTaskById(taskId);
    if (task == null) return;
    task.completed = false;
    task.chosenChoiceId = null;
  }

  void resetAll() {
    for (final t in _tasks) {
      t.completed = false;
      t.chosenChoiceId = null;
    }
  }
}