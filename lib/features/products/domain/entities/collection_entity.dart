/// CollectionEntity — domain representation of a product collection (category).
library;

/// Represents a top-level product category / collection from the catalogue.
class CollectionEntity {
  const CollectionEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String? imageUrl;

  @override
  bool operator ==(Object other) => other is CollectionEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CollectionEntity(id: $id, name: $name)';
}
