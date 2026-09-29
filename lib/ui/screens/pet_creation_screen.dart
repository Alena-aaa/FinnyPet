import 'package:flutter/material.dart';

import '../../app_controller.dart';
import '../../game/pet/pet.dart';
import 'main_navigation.dart';
import 'how_to_play_screen.dart';

class PetCreationScreen extends StatefulWidget {
  const PetCreationScreen({super.key});

  @override
  State<PetCreationScreen> createState() => _PetCreationScreenState();
}

class _PetCreationScreenState extends State<PetCreationScreen> {
  PetType _selectedType = PetType.cat;
  PetColor _selectedColor = PetColor.black;

  final TextEditingController _nameController = TextEditingController();

  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createPet() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Придумай имя питомцу'),
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await AppController.instance.petManager.createPet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        color: _selectedColor,
        name: name,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HowToPlayScreen(
            firstLaunch: true,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  String _typeName(PetType type) {
    switch (type) {
      case PetType.cat:
        return 'Кошка';
      case PetType.dog:
        return 'Собака';
      case PetType.hamster:
        return 'Хомяк';
    }
  }

  String _colorName(PetColor color) {
    switch (color) {
      case PetColor.black:
        return 'Чёрный';
      case PetColor.white:
        return 'Белый';
      case PetColor.red:
        return 'Рыжий';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABE2E3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              const Text(
                'Выбери питомца',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2F6B68),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: PetType.values.map((type) {
                  final selected = _selectedType == type;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF2F6B68)
                            : const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF28CDCA)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            type == PetType.cat
                                ? '🐱'
                                : type == PetType.dog
                                ? '🐶'
                                : '🐹',
                            style: const TextStyle(fontSize: 42),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _typeName(type),
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFFD9D9D9)
                                  : const Color(0xFF2F6B68),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              const Text(
                'Выбери цвет',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2F6B68),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: PetColor.values.map((color) {
                  final selected = _selectedColor == color;

                  final colorValue = switch (color) {
                    PetColor.black => Colors.black,
                    PetColor.white => Colors.white,
                    PetColor.red => const Color(0xFFD66A3D),
                  };

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: colorValue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF28CDCA)
                                  : const Color(0xFF2F6B68),
                              width: selected ? 5 : 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _colorName(color),
                          style: const TextStyle(
                            color: Color(0xFF2F6B68),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              const Text(
                'Как его зовут?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2F6B68),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _nameController,
                maxLength: 20,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Имя питомца',
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isCreating ? null : _createPet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6B68),
                  foregroundColor: const Color(0xFFD9D9D9),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                )
                    : const Text(
                  'СОЗДАТЬ ПИТОМЦА',
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