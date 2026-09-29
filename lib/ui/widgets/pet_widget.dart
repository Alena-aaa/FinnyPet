import 'package:flutter/material.dart';

import '../../game/pet/pet.dart';
import '../../game/pet/pet_rules.dart';

class PetWidget extends StatelessWidget {
  final Pet pet;

  const PetWidget({
    super.key,
    required this.pet,
  });

  String _petAssetPath() {
    final animalName = switch (pet.type) {
      PetType.cat => 'кошка',
      PetType.dog => 'собака',
      PetType.hamster => 'хомяк',
    };

    final colorNumber = switch (pet.color) {
      PetColor.white => 1,
      PetColor.black => 2,
      PetColor.red => 3,
    };

    final stageNumber = switch (pet.growthStage) {
      GrowthStage.baby => 1,
      GrowthStage.teen => 2,
      GrowthStage.adult => 3,
    };

    return 'assets/animals/$animalName $colorNumber.$stageNumber.png';
  }

  double _petSize() {
    switch (pet.growthStage) {
      case GrowthStage.baby:
        return 90;
      case GrowthStage.teen:
        return 120;
      case GrowthStage.adult:
        return 145;
    }
  }

  String _stageLabel() {
    switch (pet.growthStage) {
      case GrowthStage.baby:
        return 'Малыш';
      case GrowthStage.teen:
        return 'Подросток';
      case GrowthStage.adult:
        return 'Взрослый';
    }
  }

  double _growthProgress() {
    switch (pet.growthStage) {
      case GrowthStage.baby:
        return pet.growthPoints / PetRules.teenThreshold;
      case GrowthStage.teen:
        return (pet.growthPoints - PetRules.teenThreshold) /
            (PetRules.adultThreshold - PetRules.teenThreshold);
      case GrowthStage.adult:
        return 1.0;
    }
  }

  Widget _statBar({
    required String label,
    required int value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value / PetRules.statMax,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pet.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                _petAssetPath(),
                width: _petSize(),
                height: _petSize(),
                fit: BoxFit.contain,
              ),
            ),

            Text(
              _stageLabel(),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text('Рост'),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _growthProgress().clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${pet.growthPoints}'),
              ],
            ),

            const SizedBox(height: 12),

            _statBar(
              label: 'Настроение',
              value: pet.mood,
              icon: Icons.favorite,
            ),

            _statBar(
              label: 'Сытость',
              value: pet.satiety,
              icon: Icons.restaurant,
            ),

            _statBar(
              label: 'Уход',
              value: pet.care,
              icon: Icons.cleaning_services,
            ),
          ],
        ),
      ),
    );
  }
}