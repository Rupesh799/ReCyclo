class WasteItem {
  final String itemName;
  final String imageUrl;
  final String description;

  WasteItem({
    required this.itemName,
    required this.imageUrl,
    required this.description,
  });
}

class WasteItemCategory {
  final String categoryName;
  final List<WasteItem> items;

  WasteItemCategory({
    required this.categoryName,
    required this.items,
  });
}