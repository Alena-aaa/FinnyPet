import 'package:flutter/material.dart';

import '../../app_controller.dart';
import '../../models/budget_plan.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({
    super.key,
    required this.periodNumber,
  });

  final int periodNumber;

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late final TextEditingController _mandatoryController;
  late final TextEditingController _optionalController;
  late final TextEditingController _savingsController;

  @override
  void initState() {
    super.initState();

    final period = AppController.instance.periods[widget.periodNumber - 1];
    final plan = period.budgetPlan;

    _mandatoryController = TextEditingController(
      text: plan?.mandatory.toString() ?? '',
    );

    _optionalController = TextEditingController(
      text: plan?.optional.toString() ?? '',
    );

    _savingsController = TextEditingController(
      text: plan?.savings.toString() ?? '',
    );

    _mandatoryController.addListener(_update);
    _optionalController.addListener(_update);
    _savingsController.addListener(_update);
  }

  @override
  void dispose() {
    _mandatoryController.dispose();
    _optionalController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  int _value(TextEditingController controller) {
    return int.tryParse(controller.text) ?? 0;
  }

  int get _mandatory => _value(_mandatoryController);
  int get _optional => _value(_optionalController);
  int get _savings => _value(_savingsController);

  int get _total => _mandatory + _optional + _savings;

  int get _income =>
      AppController.instance.periods[widget.periodNumber - 1].income;

  int get _remaining => _income - _total;

  bool get _canConfirm =>
      _mandatory >= 0 &&
          _optional >= 0 &&
          _savings >= 0 &&
          _total <= _income;

  Future<void> _confirmPlan() async {
    if (!_canConfirm) return;

    final period =
    AppController.instance.periods[widget.periodNumber - 1];

    period.budgetPlan = BudgetPlan(
      mandatory: _mandatory,
      optional: _optional,
      savings: _savings,
    );

    await AppController.instance.saveState();

    Navigator.of(context).pop(true);
  }

  Widget _buildInput({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF2F6B68),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixText: '₽',
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOverBudget = _total > _income;

    return Scaffold(
      backgroundColor: const Color(0xFFABE2E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6B68),
        foregroundColor: const Color(0xFFD9D9D9),
        title: Text('Бюджет — период ${widget.periodNumber}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F6B68),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Твой бюджет',
                      style: TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Доступно: $_income ₽',
                      style: const TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Распредели деньги',
                style: TextStyle(
                  color: Color(0xFF2F6B68),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildInput(
                title: 'Обязательные расходы',
                subtitle: 'То, без чего нельзя обойтись',
                controller: _mandatoryController,
                icon: Icons.home_outlined,
              ),

              _buildInput(
                title: 'Желания',
                subtitle: 'Игрушки, лакомства и другие покупки',
                controller: _optionalController,
                icon: Icons.favorite_border,
              ),

              _buildInput(
                title: 'Накопления',
                subtitle: 'Деньги на будущую цель',
                controller: _savingsController,
                icon: Icons.savings_outlined,
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? const Color(0xFFFFD6D6)
                      : const Color(0xFFD9F2E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Всего распределено',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_total ₽',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Остаток'),
                        Text(
                          '$_remaining ₽',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isOverBudget
                                ? Colors.red
                                : const Color(0xFF2F6B68),
                          ),
                        ),
                      ],
                    ),
                    if (isOverBudget) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Ты распределил больше денег, чем у тебя есть.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _canConfirm ? _confirmPlan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6B68),
                  foregroundColor: const Color(0xFFD9D9D9),
                  disabledBackgroundColor: Colors.grey.shade400,
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'ПОДТВЕРДИТЬ ПЛАН',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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