import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      child: Column(
        children: [
          // Header with user info
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode 
                  ? [Colors.blue.shade800, Colors.purple.shade900]
                  : [Colors.blue.shade500, Colors.lightBlue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                authService.isAuthenticated 
                  ? (authService.currentUsername ?? '?').substring(0, 1).toUpperCase()
                  : '?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            accountName: Text(
              authService.isAuthenticated 
                ? authService.currentUsername ?? 'User'
                : 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              authService.isAuthenticated && authService.currentUser != null
                ? authService.currentUser!.email
                : 'Not signed in',
            ),
          ),
          
          // Navigation items
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Explore Spots'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ).animate().fadeIn(duration: 200.ms, delay: 100.ms),
          
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            },
          ).animate().fadeIn(duration: 200.ms, delay: 150.ms),
          
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bookings');
            },
          ).animate().fadeIn(duration: 200.ms, delay: 200.ms),
          
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('My Reviews'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reviews');
            },
          ).animate().fadeIn(duration: 200.ms, delay: 250.ms),
          
          const Divider(),
          
          // Settings and theme
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ).animate().fadeIn(duration: 200.ms, delay: 300.ms),
          
          ListTile(
            leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDarkMode ? 'Light Mode' : 'Dark Mode'),
            onTap: () {
              themeService.toggleTheme();
              Navigator.pop(context);
            },
          ).animate().fadeIn(duration: 200.ms, delay: 350.ms),
          
          const Spacer(),
          
          // Sign in/out button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (authService.isAuthenticated) {
                  authService.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully signed out')),
                  );
                } else {
                  Navigator.pushNamed(context, '/login');
                }
                Navigator.pop(context);
              },
              child: Text(
                authService.isAuthenticated ? 'Sign Out' : 'Sign In',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ).animate().fadeIn(duration: 200.ms, delay: 400.ms),
        ],
      ),
    );
  }
}
