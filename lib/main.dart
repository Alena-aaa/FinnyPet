import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'ui/screens/main_navigation.dart';
import 'ui/screens/pet_creation_screen.dart';

void main() {
  runApp(const FinnyPetApp());
}

class FinnyPetApp extends StatelessWidget {
  const FinnyPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinnyPet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const AppStartScreen(),
    );
  }
}

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  @override
  void initState() {
    super.initState();
    _checkPet();
  }

  Future<void> _checkPet() async {
    await AppController.instance.loadState();

    final pet = await AppController.instance.petManager.loadPet();

    if (!mounted) return;

    if (pet == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PetCreationScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFABE2E3),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}