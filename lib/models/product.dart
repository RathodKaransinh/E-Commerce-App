class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String creatorId;

  Product(
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.creatorId,
    this.id,
  );

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'creatorId': creatorId,
    };
  }
}
