import '../../models/transaction.dart';
/// Тема задания.
enum TaskTheme { BUDGET, SAVINGS, PURCHASE }

/// Куда применяется последствие выбора.
enum ConsequenceTarget { ECONOMY, PET }

/// Одно последствие выбора.
class Consequence {
  final ConsequenceTarget target;
  final String field;
  final int delta;
  final TransactionType? transactionType;

  const Consequence({
    required this.target,
    required this.field,
    required this.delta,
    this.transactionType,
  });
}

/// Один вариант выбора в задании.
class Choice {
  final String id;
  final String text;
  final List<Consequence> consequences;
  final String explanation;

  const Choice({
    required this.id,
    required this.text,
    required this.consequences,
    required this.explanation,
  });
}

/// Задание — ситуация с выборами и последствиями.
class Task {
  final String id;
  final TaskTheme theme;
  final int periodNumber;
  final String title;
  final String description;
  final List<Choice> choices;

  bool completed;
  String? chosenChoiceId;

  Task({
    required this.id,
    required this.theme,
    required this.periodNumber,
    required this.title,
    required this.description,
    required this.choices,
    this.completed = false,
    this.chosenChoiceId,
  });

  Choice? findChoice(String choiceId) {
    for (final c in choices) {
      if (c.id == choiceId) return c;
    }
    return null;
  }
}

