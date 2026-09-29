import 'task.dart';
import '../../models/transaction.dart';

/// 6 заданий: 2×BUDGET, 2×SAVINGS, 2×PURCHASE.
class TaskData {
  static List<Task> allTasks() => [
        _budget1(),
        _savings1(),
        _purchase1(),
        _budget2(),
        _savings2(),
        _purchase2(),
      ];

  // ---------- ПЕРИОД 1: BUDGET ----------
  static Task _budget1() => Task(
        id: 'budget_1',
        theme: TaskTheme.BUDGET,
        periodNumber: 1,
        title: 'Корм или игрушка',
        description:
            'У тебя 50 монет. Корм для питомца стоит 30, игрушка — 25. '
            'На всё сразу не хватает.',
        choices: [
          Choice(
            id: 'a',
            text: 'Купить корм, игрушку отложить',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: -30, transactionType: TransactionType.mandatory,),
              Consequence(target: ConsequenceTarget.PET, field: 'satiety', delta: 20),
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: -5),
            ],
            explanation:
                'Ты выбрал обязательное. Питомец сыт, но немного грустит без игрушки. '
                'Это нормально — сначала важное.',
          ),
          Choice(
            id: 'b',
            text: 'Купить игрушку, корм отложить',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: -25, transactionType: TransactionType.optional,),
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: 15),
              Consequence(target: ConsequenceTarget.PET, field: 'satiety', delta: -20),
            ],
            explanation:
                'Питомец рад игрушке, но голоден. Обязательные расходы важнее желаний.',
          ),
          Choice(
            id: 'c',
            text: 'Не покупать ничего',
            consequences: const [
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: -10),
              Consequence(target: ConsequenceTarget.PET, field: 'satiety', delta: -10),
            ],
            explanation:
                'Ты сохранил деньги, но питомцу нужна еда. '
                'Иногда экономия — не всегда хорошо.',
          ),
        ],
      );

  // ---------- ПЕРИОД 2: SAVINGS ----------
  static Task _savings1() => Task(
        id: 'savings_1',
        theme: TaskTheme.SAVINGS,
        periodNumber: 2,
        title: 'Копилка на домик',
        description:
            'Ты копишь на домик для питомца. У тебя 40 монет. '
            'Друг зовёт в магазин — там крутая игрушка за 35.',
        choices: [
          Choice(
            id: 'a',
            text: 'Отложить 30 в копилку, 10 оставить',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'savings', delta: 30, transactionType: TransactionType.saving,),
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: -5),
            ],
            explanation:
                'Ты выбрал цель. Питомец немного грустит без игрушки, '
                'но домик стал ближе. Это взрослое решение.',
          ),
          Choice(
            id: 'b',
            text: 'Купить игрушку за 35',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: -35, transactionType: TransactionType.optional,),
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: 20),
            ],
            explanation:
                'Питомец рад! Но цель отдалилась. Иногда хочется всё сразу — '
                'и это нормально, если помнить о цели.',
          ),
        ],
      );

  // ---------- ПЕРИОД 3: PURCHASE ----------
  static Task _purchase1() => Task(
        id: 'purchase_1',
        theme: TaskTheme.PURCHASE,
        periodNumber: 3,
        title: 'Дешёвое или нужное',
        description:
            'В магазине два корма. Дешёвый — 10 монет, но хватит на день. '
            'Хороший — 25 монет, хватит на три дня.',
        choices: [
          Choice(
            id: 'a',
            text: 'Купить дешёвый за 10',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: -10, transactionType: TransactionType.optional,),
              Consequence(target: ConsequenceTarget.PET, field: 'satiety', delta: 10),
            ],
            explanation:
                'Ты сэкономил сегодня, но завтра снова покупать. '
                'Иногда дешёвое — не выгодное.',
          ),
          Choice(
            id: 'b',
            text: 'Купить хороший за 25',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: -25, transactionType: TransactionType.optional,),
              Consequence(target: ConsequenceTarget.PET, field: 'satiety', delta: 30),
            ],
            explanation:
                'Дороже сегодня — выгоднее в итоге. Питомец сыт надолго.',
          ),
        ],
      );

  // ---------- ПЕРИОД 4: BUDGET ----------
  static Task _budget2() => Task(
        id: 'budget_2',
        theme: TaskTheme.BUDGET,
        periodNumber: 4,
        title: 'Распредели 100 монет',
        description:
            'У тебя 100 монет. План: обязательное — 50, желания — 30, '
            'накопления — 20. Но хочется купить ещё игрушку за 15.',
        choices: [
          Choice(
            id: 'a',
            text: 'Соблюдать план',
            consequences: const [
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: 5),
            ],
            explanation:
                'Ты держишь план. Это помогает копить и не тратить лишнее. '
                'Питомец гордится тобой.',
          ),
          Choice(
            id: 'b',
            text: 'Взять 15 из накоплений',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'savings', delta: -15),
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: 15),
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: 15),
            ],
            explanation:
                'Питомец рад новой игрушке, но цель отдалилась. '
                'Иногда можно, если понимаешь последствия.',
          ),
        ],
      );

  // ---------- ПЕРИОД 5: SAVINGS ----------
  static Task _savings2() => Task(
        id: 'savings_2',
        theme: TaskTheme.SAVINGS,
        periodNumber: 5,
        title: 'Соблазн',
        description:
            'Ты почти накопил на домик — осталось 20 монет. '
            'Но тут объявили скидку на игрушку за 20.',
        choices: [
          Choice(
            id: 'a',
            text: 'Не покупать, докопить',
            consequences: const [
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: -10),
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'savings', delta: 20, transactionType: TransactionType.saving,),
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: -20),
            ],
            explanation:
                'Ты выбрал цель. Питомец немного заскучал, но домик уже близко!',
          ),
          Choice(
            id: 'b',
            text: 'Купить игрушку',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: -20, transactionType: TransactionType.optional,),
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: 20),
            ],
            explanation:
                'Питомец рад, но цель отложена. Ты сам решаешь, что важнее сейчас.',
          ),
        ],
      );

  // ---------- ПЕРИОД 5: PURCHASE ----------
  static Task _purchase2() => Task(
        id: 'purchase_2',
        theme: TaskTheme.PURCHASE,
        periodNumber: 5,
        title: 'Импульс',
        description:
            'Ты увидел классную шляпу для питомца за 30 монет. '
            'Она не нужна, но очень красивая. У тебя 60 монет.',
        choices: [
          Choice(
            id: 'a',
            text: 'Купить шляпу',
            consequences: const [
              Consequence(target: ConsequenceTarget.ECONOMY, field: 'balance', delta: -30, transactionType: TransactionType.optional,),
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: 20),
            ],
            explanation:
                'Питомец в восторге! Иногда радость важнее экономии — '
                'главное, чтобы это не вошло в привычку.',
          ),
          Choice(
            id: 'b',
            text: 'Не покупать',
            consequences: const [
              Consequence(target: ConsequenceTarget.PET, field: 'mood', delta: -5),
            ],
            explanation:
                'Ты устоял перед импульсом. Это помогает копить на важное.',
          ),
        ],
      );
}

