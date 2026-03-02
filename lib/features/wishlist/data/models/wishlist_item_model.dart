/// WishlistItemModel — serializable DTO for local wishlist persistence.
library;

import 'dart:convert';

class WishlistItemModel {
  const WishlistItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.currencyCode,
    this.imageUrl,
    this.subtitle,
    this.variantId,
    this.stockLevel,
  });

  final String productId;
  final String name;
  final int price;
  final String currencyCode;
  final String? imageUrl;
  final String? subtitle;
  final String? variantId;
  final String? stockLevel;

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) =>
      WishlistItemModel(
        productId: json['productId'] as String,
        name: json['name'] as String,
        price: json['price'] as int,
        currencyCode: json['currencyCode'] as String,
        imageUrl: json['imageUrl'] as String?,
        subtitle: json['subtitle'] as String?,
        variantId: json['variantId'] as String?,
        stockLevel: json['stockLevel'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'price': price,
    'currencyCode': currencyCode,
    'imageUrl': imageUrl,
    'subtitle': subtitle,
    'variantId': variantId,
    'stockLevel': stockLevel,
  };

  static WishlistItemModel fromJsonString(String s) =>
      WishlistItemModel.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
