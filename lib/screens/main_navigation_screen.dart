import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore).animate(target: _currentIndex == 0 ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite).animate(target: _currentIndex == 1 ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person).animate(target: _currentIndex == 2 ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
