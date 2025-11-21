import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages lightweight user preferences like search history and favourites.
class UserPreferencesService extends ChangeNotifier {
  UserPreferencesService() {
    _init();
  }

  static const _searchHistoryKey = 'search_history';
  static const _favoritePlantsKey = 'favorite_plants';
  static const _recentPlantsKey = 'recent_plants';

  final List<String> _searchHistory = [];
  final List<String> _favoritePlantIds = [];
  final List<String> _recentPlantIds = [];

  SharedPreferences? _prefs;

  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  List<String> get favoritePlantIds => List.unmodifiable(_favoritePlantIds);
  List<String> get recentPlantIds => List.unmodifiable(_recentPlantIds);

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    _searchHistory
      ..clear()
      ..addAll(prefs.getStringList(_searchHistoryKey) ?? const []);

    _favoritePlantIds
      ..clear()
      ..addAll(prefs.getStringList(_favoritePlantsKey) ?? const []);

    _recentPlantIds
      ..clear()
      ..addAll(prefs.getStringList(_recentPlantsKey) ?? const []);

    notifyListeners();
  }

  /// Add a query to search history (most recent first, unique, max 10).
  Future<void> addSearchQuery(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    _searchHistory.removeWhere((q) => q.toLowerCase() == query.toLowerCase());
    _searchHistory.insert(0, query);

    const maxItems = 10;
    if (_searchHistory.length > maxItems) {
      _searchHistory.removeRange(maxItems, _searchHistory.length);
    }

    await _saveStringList(_searchHistoryKey, _searchHistory);
    notifyListeners();
  }

  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    await _saveStringList(_searchHistoryKey, _searchHistory);
    notifyListeners();
  }

  bool isFavorite(String plantId) {
    return _favoritePlantIds.contains(plantId);
  }

  /// Toggle favourite status for a plant ID.
  Future<void> toggleFavorite(String plantId) async {
    if (_favoritePlantIds.contains(plantId)) {
      _favoritePlantIds.remove(plantId);
    } else {
      _favoritePlantIds.add(plantId);
    }
    await _saveStringList(_favoritePlantsKey, _favoritePlantIds);
    notifyListeners();
  }

  /// Track recently viewed plants (most recent first, unique, max 20).
  Future<void> addRecentlyViewed(String plantId) async {
    _recentPlantIds.remove(plantId);
    _recentPlantIds.insert(0, plantId);

    const maxItems = 20;
    if (_recentPlantIds.length > maxItems) {
      _recentPlantIds.removeRange(maxItems, _recentPlantIds.length);
    }

    await _saveStringList(_recentPlantsKey, _recentPlantIds);
    notifyListeners();
  }

  Future<void> _saveStringList(String key, List<String> value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }
}


