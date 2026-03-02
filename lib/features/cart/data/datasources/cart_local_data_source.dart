/// Cart local data source — persists cart items via SharedPreferences.
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';

/// Stores cart items as a JSON string list under a single preferences key.
class CartLocalDataSource {
  CartLocalDataSource({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const _key = 'cart_items';

  Future<SharedPreferences> get _preferences async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Load all persisted cart items.
  Future<List<CartItemModel>> getCartItems() async {
    final prefs = await _preferences;
    final list = prefs.getStringList(_key) ?? [];
    return list.map(CartItemModel.fromJsonString).toList();
  }

  /// Persist the full cart list (overwrite).
  Future<void> saveCartItems(List<CartItemModel> items) async {
    final prefs = await _preferences;
    await prefs.setStringList(
      _key,
      items.map((e) => e.toJsonString()).toList(),
    );
  }

  /// Clear all persisted cart items.
  Future<void> clearCart() async {
    final prefs = await _preferences;
    await prefs.remove(_key);
  }
}
