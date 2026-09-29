/// Стадия роста питомца.
/// 0–2 growthPoints → baby
/// 3–5 growthPoints → teen
/// 6+  growthPoints → adult
enum GrowthStage { baby, teen, adult }

/// Тип питомца. 3 формы × 3 цвета = 9 комбинаций.
enum PetType { cat, dog, hamster }

/// Цвет питомца.
enum PetColor { black, white, red }

/// Состояние питомца. Иммутабельная модель.
class Pet {
  final String id;
  final PetType type;
  final PetColor color;
  final String name;

  final int mood;        // 0..100
  final int satiety;     // 0..100
  final int care;        // 0..100

  final int growthPoints;      // накопительно, только растёт
  final GrowthStage growthStage;

  const Pet({
    required this.id,
    required this.type,
    required this.color,
    required this.name,
    required this.mood,
    required this.satiety,
    required this.care,
    required this.growthPoints,
    required this.growthStage,
  });

  Pet copyWith({
    String? id,
    PetType? type,
    PetColor? color,
    String? name,
    int? mood,
    int? satiety,
    int? care,
    int? growthPoints,
    GrowthStage? growthStage,
  }) {
    return Pet(
      id: id ?? this.id,
      type: type ?? this.type,
      color: color ?? this.color,
      name: name ?? this.name,
      mood: mood ?? this.mood,
      satiety: satiety ?? this.satiety,
      care: care ?? this.care,
      growthPoints: growthPoints ?? this.growthPoints,
      growthStage: growthStage ?? this.growthStage,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'color': color.name,
        'name': name,
        'mood': mood,
        'satiety': satiety,
        'care': care,
        'growthPoints': growthPoints,
        'growthStage': growthStage.name,
      };

  factory Pet.fromMap(Map<String, dynamic> map) => Pet(
        id: map['id'] as String,
        type: PetType.values.byName(map['type'] as String),
        color: PetColor.values.byName(map['color'] as String),
        name: map['name'] as String,
        mood: map['mood'] as int,
        satiety: map['satiety'] as int,
        care: map['care'] as int,
        growthPoints: map['growthPoints'] as int,
        growthStage: GrowthStage.values.byName(map['growthStage'] as String),
      );
}

