import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/windsurf_spot.dart';
import '../services/theme_service.dart';
import '../services/windsurf_service.dart';
import '../widgets/spot_card.dart';
import 'spot_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WindsurfService _windsurfService = WindsurfService();
  late List<WindsurfSpot> _spots;
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Beginner', 'Intermediate', 'Advanced', 'Expert'];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _spots = _windsurfService.getSpots();
      _isLoading = false;
    });
  }

  List<WindsurfSpot> get _filteredSpots {
    if (_selectedFilter == 'All') {
      return _spots;
    }
    return _spots.where((spot) => 
      spot.difficulty.toLowerCase().contains(_selectedFilter.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Windsurf',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: isDarkMode 
                                ? [Colors.lightBlue, Colors.purple] 
                                : [Colors.blue, Colors.indigo],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 4),
                      Text(
                        'Discover the best spots',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: isDarkMode ? Colors.amber : Colors.blueGrey,
                    ),
                    onPressed: () {
                      themeService.toggleTheme();
                    },
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                ],
              ),
            ),
            
            // Filters
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      selectedColor: isDarkMode ? Colors.blue[700] : Colors.blue[400],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ).animate().fadeIn(delay: 100.ms * index, duration: 400.ms);
                },
              ),
            ),
            
            // Spots list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSpots.isEmpty
                      ? Center(
                          child: Text(
                            'No spots found for $_selectedFilter level',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: _filteredSpots.length,
                          itemBuilder: (context, index) {
                            final spot = _filteredSpots[index];
                            return SpotCard(
                              spot: spot,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SpotDetailsScreen(spot: spot),
                                  ),
                                );
                              },
                            ).animate().fadeIn(
                                  delay: Duration(milliseconds: 100 * index),
                                  duration: const Duration(milliseconds: 500),
                                );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
