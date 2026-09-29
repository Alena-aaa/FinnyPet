import 'data/period_configs.dart';
import 'game/pet/shared_preferences_pet_storage.dart';
import 'game/pet/pet_manager.dart';
import 'game/tasks/consequence_manager.dart';
import 'game/tasks/task_manager.dart';
import 'models/player.dart';
import 'models/savings_goal.dart';
import 'models/game_period.dart';
import 'models/transaction.dart';
import 'models/period_fact.dart';
import 'models/budget_plan.dart';
import 'services/economy_service.dart';
import 'services/period_service.dart';
import 'services/growth_service.dart';
import 'services/local_storage_service.dart';

class AppController {
  AppController._();

  static final AppController instance = AppController._();

  final PetManager petManager = PetManager(
    storage: SharedPreferencesPetStorage(),
  );

  final EconomyService economyService = EconomyService();
  final PeriodService periodService = PeriodService();
  final GrowthService growthService = GrowthService();
  final LocalStorageService localStorageService = LocalStorageService();

  final List<Transaction> currentPeriodTransactions = [];
  final List<Transaction> transactions = [];
  final List<PeriodFact> completedPeriodFacts = [];
  final Map<int, Set<int>> purchasedItemsByPeriod = {};

  Set<int> get purchasedItems {
    final period = player.currentPeriod;

    return purchasedItemsByPeriod.putIfAbsent(
      period,
          () => <int>{},
    );
  }

  PeriodFact? lastPeriodFact;
  int lastPeriodGrowthPoints = 0;

  late final Player player = Player(
    id: 'player_1',
    name: 'Player',
    currentBalance: periodConfigs.first.income,
    currentPeriod: 1,
  );

  final List<SavingsGoal> savingsGoals = [
    SavingsGoal(
      id: 'goal_1',
      name: 'Домик для питомца',
      targetAmount: 100,
      savedAmount: 0,
    ),
    SavingsGoal(
      id: 'goal_2',
      name: 'Новая лежанка',
      targetAmount: 150,
      savedAmount: 0,
    ),
    SavingsGoal(
      id: 'goal_3',
      name: 'Игровой комплекс',
      targetAmount: 200,
      savedAmount: 0,
    ),
  ];

  SavingsGoal? selectedSavingsGoal;

  SavingsGoal get currentSavingsGoal =>
      selectedSavingsGoal ?? savingsGoals.first;

  late final ConsequenceManager consequenceManager = ConsequenceManager(
    petManager: petManager,
    economyService: economyService,
    player: player,
    getSavingsGoal: () => currentSavingsGoal,
  );

  late final TaskManager taskManager = TaskManager(
    consequenceManager: consequenceManager,
  );

  final List<GamePeriod> periods = [
    GamePeriod(
      number: periodConfigs[0].number,
      income: periodConfigs[0].income,
    ),
    GamePeriod(
      number: periodConfigs[1].number,
      income: periodConfigs[1].income,
    ),
    GamePeriod(
      number: periodConfigs[2].number,
      income: periodConfigs[2].income,
    ),
    GamePeriod(
      number: periodConfigs[3].number,
      income: periodConfigs[3].income,
    ),
    GamePeriod(
      number: periodConfigs[4].number,
      income: periodConfigs[4].income,
    ),
  ];

  Future<void> completeCurrentPeriod() async {
    final currentPeriod = player.currentPeriod;

    if (!taskManager.isCurrentPeriodCompleted(currentPeriod)) {
      return;
    }

    final fact = periodService.calculateFact(
      currentPeriodTransactions,
      periods[currentPeriod - 1].budgetPlan,
    );

    completedPeriodFacts.add(fact);
    lastPeriodFact = fact;

    final totalGrowthPoints = growthService.calculateGrowthPoints(
      completedPeriodFacts,
    );

    final previousGrowthPoints = completedPeriodFacts.length > 1
        ? growthService.calculateGrowthPoints(
      completedPeriodFacts.sublist(
        0,
        completedPeriodFacts.length - 1,
      ),
    )
        : 0;

    final newGrowthPoints = totalGrowthPoints - previousGrowthPoints;
    lastPeriodGrowthPoints = newGrowthPoints;

    await petManager.addGrowthPoints(newGrowthPoints);

    currentPeriodTransactions.clear();

    await saveState();
  }

  Future<void> moveToNextPeriod() async {
    final currentPeriod = player.currentPeriod;

    if (currentPeriod >= periodConfigs.length) {
      return;
    }

    final nextPeriod = currentPeriod + 1;
    final income = periodConfigs[nextPeriod - 1].income;

    player.currentPeriod = nextPeriod;
    player.currentBalance = income;

    final transaction = Transaction(
      type: TransactionType.income,
      amount: income,
      source: 'Доход за период $nextPeriod',
      period: nextPeriod,
      timestamp: DateTime.now(),
    );

    currentPeriodTransactions.add(transaction);
    transactions.add(transaction);

    await saveState();
  }

  Future<void> saveState() async {
    final taskStates = taskManager.getAllTasks().map((task) {
      return <String, dynamic>{
        'taskId': task.id,
        'completed': task.completed,
        'chosenChoiceId': task.chosenChoiceId,
      };
    }).toList();

    await localStorageService.saveState(
      player: player,
      savingsGoals: savingsGoals,
      selectedSavingsGoal: selectedSavingsGoal,
      periods: periods,
      purchasedItemsByPeriod: purchasedItemsByPeriod,
      transactions: transactions,
      currentPeriodTransactions: currentPeriodTransactions,
      completedPeriodFacts: completedPeriodFacts,
      lastPeriodFact: lastPeriodFact,
      lastPeriodGrowthPoints: lastPeriodGrowthPoints,
      taskStates: taskStates,
    );
  }

  Future<void> loadState() async {
    final data = await localStorageService.loadState();

    if (data == null) {
      return;
    }

    // Игрок.
    final playerData = data['player'] as Map<String, dynamic>;

    player.id = playerData['id'] as String;
    player.name = playerData['name'] as String;
    player.currentBalance = playerData['currentBalance'] as int;
    player.currentPeriod = playerData['currentPeriod'] as int;

    // Цели накоплений.
    final savedGoals =
    (data['savingsGoals'] as List<dynamic>? ?? []);

    for (final savedGoal in savedGoals) {
      final map = savedGoal as Map<String, dynamic>;

      final goal = savingsGoals.where(
            (g) => g.id == map['id'],
      ).firstOrNull;

      if (goal == null) continue;

      goal.savedAmount = map['savedAmount'] as int;
    }

    final selectedGoalId =
    data['selectedSavingsGoalId'] as String?;

    if (selectedGoalId != null) {
      selectedSavingsGoal = savingsGoals.where(
            (goal) => goal.id == selectedGoalId,
      ).firstOrNull;
    }

    // Периоды.
    final savedPeriods =
    (data['periods'] as List<dynamic>? ?? []);

    for (final savedPeriod in savedPeriods) {
      final map = savedPeriod as Map<String, dynamic>;

      final number = map['number'] as int;

      if (number < 1 || number > periods.length) {
        continue;
      }

      final period = periods[number - 1];

      final budgetData =
      map['budgetPlan'] as Map<String, dynamic>?;

      if (budgetData != null) {
        period.budgetPlan = BudgetPlan(
          mandatory: budgetData['mandatory'] as int,
          optional: budgetData['optional'] as int,
          savings: budgetData['savings'] as int,
        );
      } else {
        period.budgetPlan = null;
      }

      period.actualMandatory =
          map['actualMandatory'] as int? ?? 0;
      period.actualOptional =
          map['actualOptional'] as int? ?? 0;
      period.actualSavings =
          map['actualSavings'] as int? ?? 0;
      period.completed =
          map['completed'] as bool? ?? false;
    }

    // Купленные товары.
    purchasedItemsByPeriod.clear();

    final savedPurchases =
    data['purchasedItemsByPeriod']
    as Map<String, dynamic>?;

    if (savedPurchases != null) {
      for (final entry in savedPurchases.entries) {
        final period = int.tryParse(entry.key);

        if (period == null) continue;

        final items = entry.value as List<dynamic>;

        purchasedItemsByPeriod[period] = items
            .map((item) => item as int)
            .toSet();
      }
    }

    // Текущие транзакции.
    currentPeriodTransactions.clear();

    final savedCurrentTransactions =
        data['currentPeriodTransactions']
        as List<dynamic>? ?? [];

    for (final item in savedCurrentTransactions) {
      currentPeriodTransactions.add(
        _transactionFromMap(
          item as Map<String, dynamic>,
        ),
      );
    }

    // История транзакций.
    transactions.clear();

    final savedTransactions =
        data['transactions'] as List<dynamic>? ?? [];

    for (final item in savedTransactions) {
      transactions.add(
        _transactionFromMap(
          item as Map<String, dynamic>,
        ),
      );
    }

    // Результаты периодов.
    completedPeriodFacts.clear();

    final savedFacts =
        data['completedPeriodFacts'] as List<dynamic>? ?? [];

    for (final item in savedFacts) {
      completedPeriodFacts.add(
        _periodFactFromMap(
          item as Map<String, dynamic>,
        ),
      );
    }

    // Последний результат.
    final lastFactData =
    data['lastPeriodFact'] as Map<String, dynamic>?;

    lastPeriodFact = lastFactData == null
        ? null
        : _periodFactFromMap(lastFactData);

    lastPeriodGrowthPoints =
        data['lastPeriodGrowthPoints'] as int? ?? 0;

    // Состояние заданий.
    final savedTaskStates =
    (data['taskStates'] as List<dynamic>? ?? [])
        .map(
          (item) => Map<String, dynamic>.from(
        item as Map,
      ),
    )
        .toList();

    taskManager.restoreTaskState(savedTaskStates);
  }

  Transaction _transactionFromMap(
      Map<String, dynamic> map,
      ) {
    return Transaction(
      type: TransactionType.values.byName(
        map['type'] as String,
      ),
      amount: map['amount'] as int,
      source: map['source'] as String,
      period: map['period'] as int,
      timestamp: DateTime.parse(
        map['timestamp'] as String,
      ),
    );
  }

  PeriodFact _periodFactFromMap(
      Map<String, dynamic> map,
      ) {
    final planData =
    map['plan'] as Map<String, dynamic>?;

    BudgetPlan? plan;

    if (planData != null) {
      plan = BudgetPlan(
        mandatory: planData['mandatory'] as int,
        optional: planData['optional'] as int,
        savings: planData['savings'] as int,
      );
    }

    return PeriodFact(
      mandatory: map['mandatory'] as int,
      optional: map['optional'] as int,
      savings: map['savings'] as int,
      plan: plan,
    );
  }

  Future<void> resetDemoProfile() async {
    taskManager.resetAll();

    await petManager.resetPet();

    for (final goal in savingsGoals) {
      goal.savedAmount = 0;
    }

    selectedSavingsGoal = null;

    currentPeriodTransactions.clear();
    transactions.clear();
    completedPeriodFacts.clear();
    purchasedItemsByPeriod.clear();

    lastPeriodFact = null;
    lastPeriodGrowthPoints = 0;

    for (final period in periods) {
      period.completed = false;
      period.budgetPlan = null;
      period.actualMandatory = 0;
      period.actualOptional = 0;
      period.actualSavings = 0;
    }

    player.currentPeriod = 1;
    player.currentBalance = periodConfigs.first.income;

    await localStorageService.clear();
  }
}