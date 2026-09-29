import 'package:flutter/material.dart';
import '../../app_controller.dart';
import '../../game/pet/pet.dart';
import 'main_navigation.dart';

class HowToPlayScreen extends StatelessWidget {
  final bool firstLaunch;

  const HowToPlayScreen({
    super.key,
    this.firstLaunch = false,
  });

  String _petDescription() {
    final pet = AppController.instance.petManager.getPet();

    if (pet == null) {
      return 'Твой питомец будет помогать тебе учиться обращаться с деньгами.';
    }

    final typeName = switch (pet.type) {
      PetType.cat => 'Кошка',
      PetType.dog => 'Собака',
      PetType.hamster => 'Хомяк',
    };

    return 'Твой питомец — $typeName ${pet.name}!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABE2E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6B68),
        title: const Text(
          'Как играть?',
          style: TextStyle(
            fontFamily: 'Handjet',
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: !firstLaunch,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Добро пожаловать в FinnyPet!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Handjet',
                  color: Color(0xFF2F6B68),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4EA6A2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _petDescription(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const SizedBox(height: 12),
              const Text(
                'Здесь ты будешь заботиться о питомце и учиться обращаться с деньгами.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2F6B68),
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                icon: Icons.pets,
                title: 'Твой питомец',
                text:
                'Заботься о питомце, принимай финансовые решения и помогай ему расти.',
              ),

              const SizedBox(height: 12),

              _buildSection(
                icon: Icons.account_balance_wallet,
                title: 'Обязательное',
                text:
                'Это то, что действительно нужно. Сначала подумай о важных расходах.',
              ),

              const SizedBox(height: 12),

              _buildSection(
                icon: Icons.favorite,
                title: 'Желания',
                text:
                'Это приятные покупки, которые хочется сделать, но без них можно обойтись.',
              ),

              const SizedBox(height: 12),

              _buildSection(
                icon: Icons.savings,
                title: 'Накопления',
                text:
                'Откладывай монеты на большую цель и постепенно приближайся к ней.',
              ),

              const SizedBox(height: 24),

              const Text(
                'За несколько периодов ты увидишь, как твои решения влияют на питомца и его развитие.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF2F6B68),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (firstLaunch) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainNavigation(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6B68),
                    foregroundColor: const Color(0xFFD9D9D9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    firstLaunch ? 'Начать игру' : 'Понятно',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4EA6A2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 32,
            color: const Color(0xFFD9D9D9),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}