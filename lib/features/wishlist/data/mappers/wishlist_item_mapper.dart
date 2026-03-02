/// WishlistItemMapper — converts WishlistItemModel ↔ WishlistItemEntity.
library;

import '../../domain/entities/wishlist_item_entity.dart';
import '../models/wishlist_item_model.dart';

abstract final class WishlistItemMapper {
  static WishlistItemEntity toEntity(WishlistItemModel model) =>
      WishlistItemEntity(
        productId: model.productId,
        name: model.name,
        price: model.price,
        currencyCode: model.currencyCode,
        imageUrl: model.imageUrl,
        subtitle: model.subtitle,
        variantId: model.variantId,
        stockLevel: model.stockLevel,
      );

  static WishlistItemModel toModel(WishlistItemEntity entity) =>
      WishlistItemModel(
        productId: entity.productId,
        name: entity.name,
        price: entity.price,
        currencyCode: entity.currencyCode,
        imageUrl: entity.imageUrl,
        subtitle: entity.subtitle,
        variantId: entity.variantId,
        stockLevel: entity.stockLevel,
      );
}
