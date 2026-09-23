import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/partner.dart';

/// Provider managing employee favorited partner venues with local persistence.
///
/// Stores favorite merchant IDs in [SharedPreferences] to preserve selections
/// across app sessions and device restarts.
class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'kollektivo_favorite_partner_ids';

  final Set<String> _favoriteIds = {};
  bool _isInitialized = false;

  FavoritesProvider() {
    _loadFavorites();
  }

  bool get isInitialized => _isInitialized;
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get count => _favoriteIds.length;

  /// Checks if a partner ID is marked as favorite
  bool isFavorite(String partnerId) => _favoriteIds.contains(partnerId);

  /// Toggles favorite status for a partner venue
  Future<void> toggleFavorite(String partnerId) async {
    if (_favoriteIds.contains(partnerId)) {
      _favoriteIds.remove(partnerId);
    } else {
      _favoriteIds.add(partnerId);
    }
    notifyListeners();
    await _persistFavorites();
  }

  /// Filters a list of partners returning only favorited items
  List<PartnerModel> filterFavorites(List<PartnerModel> partners) {
    return partners.where((p) => _favoriteIds.contains(p.id)).toList();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_storageKey);
      if (savedList != null) {
        _favoriteIds.clear();
        _favoriteIds.addAll(savedList);
      } else {
        // Default initial favorites for demo purposes
        _favoriteIds.addAll(['p1', 'p3']);
      }
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _persistFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _favoriteIds.toList());
    } catch (e) {
      debugPrint('Failed to save favorites: $e');
    }
  }
}
