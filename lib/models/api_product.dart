class ApiProduct {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String thumbnail;

  const ApiProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.thumbnail,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final price = json['price'];
    if (id is! num || price is! num) {
      throw const FormatException('Тауар ID немесе бағасы қате форматта.');
    }
    return ApiProduct(
      id: id.toInt(),
      title: _readString(json, 'title'),
      description: _readString(json, 'description'),
      category: _readString(json, 'category'),
      price: price.toDouble(),
      thumbnail: _readThumbnail(json),
    );
  }

  factory ApiProduct.fromMap(Map<String, Object?> map) => ApiProduct(
        id: map['id']! as int,
        title: map['title']! as String,
        description: map['description']! as String,
        category: map['category']! as String,
        price: (map['price']! as num).toDouble(),
        thumbnail: map['thumbnail']! as String,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'thumbnail': thumbnail,
      };

  Map<String, Object?> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'thumbnail': thumbnail,
      };

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Тауардың "$key" өрісі мәтін болуы керек.');
    }
    return value;
  }

  static String _readThumbnail(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'];
    if (thumbnail is String) return thumbnail;
    final images = json['images'];
    if (images is List && images.isNotEmpty && images.first is String) {
      return images.first as String;
    }
    return '';
  }
}
