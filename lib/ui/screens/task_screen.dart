import 'package:flutter/material.dart';
import '../../game/tasks/task.dart';
import '../../game/tasks/task_manager.dart';
import '../../game/tasks/consequence_manager.dart';

/// Экран задания. Показывает ситуацию, варианты выбора,
/// после выбора — последствия и объяснение.
class TaskScreen extends StatefulWidget {
  final Task task;
  final TaskManager taskManager;
  final VoidCallback? onCompleted;

  const TaskScreen({
    super.key,
    required this.task,
    required this.taskManager,
    this.onCompleted,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  ChoiceResult? _result;
  bool _loading = false;

  Future<void> _onChoose(String choiceId) async {
    setState(() => _loading = true);

    final result = await widget.taskManager.submitChoice(
      taskId: widget.task.id,
      choiceId: choiceId,
    );

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  // ---------- UI: до выбора ----------

  Widget _buildChoices() {
    return Column(
      children: widget.task.choices.map((choice) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : () => _onChoose(choice.id),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  choice.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------- UI: после выбора ----------

  Widget _buildResult() {
    final result = _result!;
    final report = result.report;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Что получилось:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Последствия для питомца
        if (report != null && report.applied.isNotEmpty) ...[
          const Text('🐱 Питомец:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ...report.applied.map((c) => _consequenceRow(c.field, c.delta)),
          const SizedBox(height: 8),
        ],

        // Отложенные (ECONOMY — Алёна применит позже)
        if (report != null && report.pending.isNotEmpty) ...[
          const Text('💰 Экономика (применится позже):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ...report.pending.map((c) => _consequenceRow(c.field, c.delta)),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 8),

        // Объяснение
        if (result.explanation != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Text(
              result.explanation!,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (widget.onCompleted != null) {
                widget.onCompleted!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Дальше', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _consequenceRow(String field, int delta) {
    final sign = delta > 0 ? '+' : '';
    final color = delta > 0 ? Colors.green.shade700 : Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(_translateField(field))),
          Text(
            '$sign$delta',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  String _translateField(String field) {
    switch (field) {
      case 'mood':
        return '😊 Настроение';
      case 'satiety':
        return '🍖 Сытость';
      case 'care':
        return '🧼 Уход';
      case 'balance':
        return '💰 Баланс';
      case 'savings':
        return '🏦 Накопления';
      default:
        return field;
    }
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_themeLabel(widget.task.theme)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок задания
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Описание-ситуация
            Text(
              widget.task.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Выбор или результат
            if (_result == null) _buildChoices() else _buildResult(),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(TaskTheme theme) {
    switch (theme) {
      case TaskTheme.BUDGET:
        return 'Бюджет';
      case TaskTheme.SAVINGS:
        return 'Накопления';
      case TaskTheme.PURCHASE:
        return 'Покупки';
    }
  }
}