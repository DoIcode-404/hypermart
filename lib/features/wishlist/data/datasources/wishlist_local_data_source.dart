/// Wishlist local data source — persists favourites via SharedPreferences.
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/wishlist_item_model.dart';

class WishlistLocalDataSource {
  WishlistLocalDataSource({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const _key = 'wishlist_items';

  Future<SharedPreferences> get _preferences async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<List<WishlistItemModel>> getWishlistItems() async {
    final prefs = await _preferences;
    final list = prefs.getStringList(_key) ?? [];
    return list.map(WishlistItemModel.fromJsonString).toList();
  }

  Future<void> saveWishlistItems(List<WishlistItemModel> items) async {
    final prefs = await _preferences;
    await prefs.setStringList(
      _key,
      items.map((e) => e.toJsonString()).toList(),
    );
  }

  Future<void> clearWishlist() async {
    final prefs = await _preferences;
    await prefs.remove(_key);
  }
}
