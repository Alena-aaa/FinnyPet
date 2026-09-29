import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'shop_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State createState() => _MainNavigationState();
}

class _MainNavigationState extends State {
  int _currentIndex = 0;

  final List _screens = [
    const HomeScreen(),
    const StatsScreen(),
    const ShopScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2F6B68),
          borderRadius: BorderRadius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF28CDCA),
          unselectedItemColor: const Color(0xFFD9D9D9),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Прогресс'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Магазин'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}