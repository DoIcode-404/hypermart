/// CartItemMapper — converts CartItemModel ↔ CartItemEntity.
library;

import '../../domain/entities/cart_item_entity.dart';
import '../models/cart_item_model.dart';

abstract final class CartItemMapper {
  static CartItemEntity toEntity(CartItemModel model) => CartItemEntity(
    productId: model.productId,
    variantId: model.variantId,
    name: model.name,
    price: model.price,
    currencyCode: model.currencyCode,
    quantity: model.quantity,
    imageUrl: model.imageUrl,
    subtitle: model.subtitle,
  );

  static CartItemModel toModel(CartItemEntity entity) => CartItemModel(
    productId: entity.productId,
    variantId: entity.variantId,
    name: entity.name,
    price: entity.price,
    currencyCode: entity.currencyCode,
    quantity: entity.quantity,
    imageUrl: entity.imageUrl,
    subtitle: entity.subtitle,
  );
}
