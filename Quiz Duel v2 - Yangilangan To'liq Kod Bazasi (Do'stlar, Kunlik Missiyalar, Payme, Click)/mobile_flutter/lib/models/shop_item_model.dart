class ShopItemModel {
  final int id;
  final String title;
  final String description;
  final String itemType;
  final int priceUzs;
  final int coinPrice;
  final int value;
  final String icon;
  final bool isPopular;

  ShopItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.itemType,
    required this.priceUzs,
    required this.coinPrice,
    required this.value,
    required this.icon,
    required this.isPopular,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      itemType: json['item_type'] ?? '',
      priceUzs: json['price_uzs'] ?? 0,
      coinPrice: json['coin_price'] ?? 0,
      value: json['value'] ?? 1,
      icon: json['icon'] ?? 'shopping_bag',
      isPopular: (json['is_popular'] == 1 || json['is_popular'] == true),
    );
  }
}
