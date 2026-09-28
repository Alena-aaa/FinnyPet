import '../pet/pet_manager.dart';
import 'task.dart';

/// Одно изменение — что изменилось после применения.
class AppliedChange {
  final ConsequenceTarget target;
  final String field;
  final int delta;

  const AppliedChange({
    required this.target,
    required this.field,
    required this.delta,
  });

  @override
  String toString() => '${target.name}.$field: $delta';
}

/// Отчёт: что применилось, что отложено.
class ConsequenceReport {
  /// Что реально применилось сейчас.
  final List<AppliedChange> applied;

  /// Что пока не применилось (ECONOMY — ждём Алёну).
  final List<AppliedChange> pending;

  const ConsequenceReport({
    required this.applied,
    required this.pending,
  });
}

/// Применяет последствия выбора ребёнка.
///
/// - PET → вызывает PetManager.applyConsequences
/// - ECONOMY → пока сохраняет в pending (Алёны ещё нет)
class ConsequenceManager {
  final PetManager petManager;

  ConsequenceManager({required this.petManager});

  /// Применить список последствий.
  Future<ConsequenceReport> apply(List<Consequence> consequences) async {
    final applied = <AppliedChange>[];
    final pending = <AppliedChange>[];

    final petConsequences = <Map<String, dynamic>>[];

    for (final c in consequences) {
      switch (c.target) {
        case ConsequenceTarget.PET:
          petConsequences.add({
            'field': c.field,
            'delta': c.delta,
          });
          applied.add(AppliedChange(
            target: c.target,
            field: c.field,
            delta: c.delta,
          ));
          break;

        case ConsequenceTarget.ECONOMY:
          pending.add(AppliedChange(
            target: c.target,
            field: c.field,
            delta: c.delta,
          ));
          break;
      }
    }

    if (petConsequences.isNotEmpty) {
      await petManager.applyConsequences(petConsequences);
    }

    return ConsequenceReport(applied: applied, pending: pending);
  }
}