/// CartItemModel — serializable DTO for local cart persistence.
library;

import 'dart:convert';

/// JSON-serializable version of [CartItemEntity].
/// Stored as a JSON string list in SharedPreferences.
class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.variantId,
    required this.name,
    required this.price,
    required this.currencyCode,
    required this.quantity,
    this.imageUrl,
    this.subtitle,
  });

  final String productId;
  final String variantId;
  final String name;
  final int price;
  final String currencyCode;
  final int quantity;
  final String? imageUrl;
  final String? subtitle;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    productId: json['productId'] as String,
    variantId: json['variantId'] as String,
    name: json['name'] as String,
    price: json['price'] as int,
    currencyCode: json['currencyCode'] as String,
    quantity: json['quantity'] as int,
    imageUrl: json['imageUrl'] as String?,
    subtitle: json['subtitle'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'variantId': variantId,
    'name': name,
    'price': price,
    'currencyCode': currencyCode,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'subtitle': subtitle,
  };

  static CartItemModel fromJsonString(String s) =>
      CartItemModel.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
