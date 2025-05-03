import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/windsurf_spot.dart';
import '../services/favorites_service.dart';
import '../services/windsurf_service.dart';
import '../widgets/spot_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  List<WindsurfSpot> _favoriteSpots = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteSpots();
  }

  Future<void> _loadFavoriteSpots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favoritesService = Provider.of<FavoritesService>(context, listen: false);
      final windsurfService = Provider.of<WindsurfService>(context, listen: false);
      
      // Get all spots
      final allSpots = await windsurfService.getSpots();
      
      // Filter to only include favorites
      _favoriteSpots = allSpots
          .where((spot) => favoritesService.isFavorite(spot.id))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavoriteSpots,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteSpots.isEmpty
              ? _buildEmptyState(isDarkMode)
              : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add windsurf spots to your favorites to see them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Spots'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavoriteSpots,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteSpots.length,
        itemBuilder: (context, index) {
          final spot = _favoriteSpots[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SpotCard(
              spot: spot,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/spot-details',
                  arguments: spot,
                );
              },
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms * index);
        },
      ),
    );
  }
}
