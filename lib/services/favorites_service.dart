import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/windsurf_spot.dart';

class FavoritesService extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  bool _isLoading = true;

  FavoritesService() {
    _loadFavorites();
  }

  bool get isLoading => _isLoading;
  
  bool isFavorite(String spotId) {
    return _favoriteIds.contains(spotId);
  }

  Set<String> get favoriteIds => Set.from(_favoriteIds);
  
  List<WindsurfSpot> getFavoriteSpots() {
    // This is a placeholder - in a real app, you would fetch the actual spots from a database
    // For demo purposes, we'll return an empty list that will be populated when integrated with WindsurfService
    return [];
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites') ?? [];
      _favoriteIds.addAll(favorites);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String spotId) async {
    if (_favoriteIds.contains(spotId)) {
      _favoriteIds.remove(spotId);
    } else {
      _favoriteIds.add(spotId);
    }
    
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteIds.toList());
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  List<WindsurfSpot> filterFavorites(List<WindsurfSpot> allSpots) {
    return allSpots.where((spot) => _favoriteIds.contains(spot.id)).toList();
  }
}
