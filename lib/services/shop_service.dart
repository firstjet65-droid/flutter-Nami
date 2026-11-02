import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import 'shop_database.dart';

const _productIcons = <String, IconData>{
  'headphones': Icons.headphones,
  'watch': Icons.watch,
  'directions_run': Icons.directions_run,
  'backpack': Icons.backpack,
  'light': Icons.light,
  'speaker': Icons.speaker,
  'shopping_bag_outlined': Icons.shopping_bag_outlined,
};

class ShopService extends ChangeNotifier {
  final ShopDatabase _shopDatabase;
  final List<Product> _products = [];
  final Map<int, int> _cart = {};
  final Set<int> _favorites = {};
  final List<ShopOrder> _orders = [];

  Database? _database;
  Future<void>? _initialization;
  bool _signedIn = false;
  String _userName = 'Қонақ';
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  ShopService({ShopDatabase? database})
      : _shopDatabase = database ?? ShopDatabase();

  List<Product> get products => List.unmodifiable(_products);
  Map<int, int> get cart => Map.unmodifiable(_cart);
  Set<int> get favorites => Set.unmodifiable(_favorites);
  List<ShopOrder> get orders => List.unmodifiable(_orders);
  bool get signedIn => _signedIn;
  String get userName => _userName;
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  int get cartCount => _cart.values.fold(0, (sum, quantity) => sum + quantity);

  int get total => _cart.entries.fold(0, (sum, entry) {
        final product = _productById(entry.key);
        return sum + product.price * entry.value;
      });

  Future<void> initialize() {
    final pending = _initialization;
    if (pending != null) return pending;
    final initialization = _loadFromDatabase();
    _initialization = initialization;
    return initialization;
  }

  Future<void> _loadFromDatabase() async {
    try {
      await _readDatabase();
    } on Exception {
      _initialization = null;
      rethrow;
    }
  }

  Future<void> _readDatabase() async {
    final database = await _shopDatabase.open();
    final productRows = await database.query('products', orderBy: 'id');
    final cartRows = await database.query('cart_items');
    final favoriteRows = await database.query('favorites');
    final orderRows = await database.query('orders', orderBy: 'id DESC');
    final settingsRows = await database.query('app_settings');

    _products
      ..clear()
      ..addAll(productRows.map(_productFromRow));
    _cart
      ..clear()
      ..addEntries(
        cartRows.map(
          (row) => MapEntry(
            row['product_id']! as int,
            row['quantity']! as int,
          ),
        ),
      );
    _favorites
      ..clear()
      ..addAll(favoriteRows.map((row) => row['product_id']! as int));
    _orders
      ..clear()
      ..addAll(orderRows.map(_orderFromRow));
    for (final row in settingsRows) {
      switch (row['setting_key']) {
        case 'dark_mode':
          _darkMode = row['setting_value'] == 'true';
          break;
        case 'notifications_enabled':
          _notificationsEnabled = row['setting_value'] == 'true';
          break;
      }
    }
    _database = database;
    notifyListeners();
  }

  Future<void> close() => _shopDatabase.close();

  Product _productFromRow(Map<String, Object?> row) => Product(
        id: row['id']! as int,
        name: row['name']! as String,
        category: row['category']! as String,
        price: row['price']! as int,
        icon: _productIcons[row['icon_key']! as String] ??
            Icons.shopping_bag_outlined,
        description: row['description']! as String,
        imageUrl: row['image_url']! as String,
      );

  ShopOrder _orderFromRow(Map<String, Object?> row) => ShopOrder(
        id: row['id']! as int,
        itemCount: row['item_count']! as int,
        total: row['total']! as int,
        address: row['address']! as String,
        paymentMethod: row['payment_method']! as String,
        createdAt: DateTime.parse(row['created_at']! as String),
      );

  Database get _db {
    final database = _database;
    if (database == null) {
      throw StateError('Алдымен SQLite дерекқорын initialize() арқылы ашыңыз.');
    }
    return database;
  }

  Product _productById(int id) =>
      _products.firstWhere((product) => product.id == id);

  Future<void> addToCart(Product product) async {
    final quantity = (_cart[product.id] ?? 0) + 1;
    await _db.insert(
      'cart_items',
      {'product_id': product.id, 'quantity': quantity},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _cart[product.id] = quantity;
    notifyListeners();
  }

  Future<void> changeQuantity(int id, int delta) async {
    final next = (_cart[id] ?? 0) + delta;
    if (next <= 0) {
      await _db.delete('cart_items', where: 'product_id = ?', whereArgs: [id]);
      _cart.remove(id);
    } else {
      await _db.update(
        'cart_items',
        {'quantity': next},
        where: 'product_id = ?',
        whereArgs: [id],
      );
      _cart[id] = next;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    if (_favorites.contains(id)) {
      await _db.delete('favorites', where: 'product_id = ?', whereArgs: [id]);
      _favorites.remove(id);
    } else {
      await _db.insert('favorites', {'product_id': id});
      _favorites.add(id);
    }
    notifyListeners();
  }

  Future<void> authenticate(String name) async {
    _signedIn = true;
    _userName = name;
    notifyListeners();
  }

  void signOut() {
    _signedIn = false;
    _userName = 'Қонақ';
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    await _saveSetting('dark_mode', enabled.toString());
    _darkMode = enabled;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _saveSetting('notifications_enabled', enabled.toString());
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  Future<void> _saveSetting(String key, String value) => _db.insert(
      'app_settings',
      {
        'setting_key': key,
        'setting_value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace);

  String _iconKey(IconData icon) {
    if (icon == Icons.headphones) return 'headphones';
    if (icon == Icons.watch) return 'watch';
    if (icon == Icons.directions_run) return 'directions_run';
    if (icon == Icons.backpack) return 'backpack';
    if (icon == Icons.light) return 'light';
    if (icon == Icons.speaker) return 'speaker';
    return 'shopping_bag_outlined';
  }

  Future<void> saveProduct({
    int? id,
    required String name,
    required String category,
    required int price,
    required String description,
    required String imageUrl,
  }) async {
    final product = Product(
      id: id ?? 0,
      name: name,
      category: category,
      price: price,
      icon: Icons.shopping_bag_outlined,
      description: description,
      imageUrl: imageUrl,
    );
    final row = {
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'icon_key': _iconKey(product.icon),
      'description': product.description,
      'image_url': product.imageUrl,
    };
    final int savedId;
    if (id == null) {
      savedId = await _db.insert('products', row);
    } else {
      final updated = await _db.update(
        'products',
        row,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (updated == 0) {
        throw StateError('Өңделетін тауар дерекқордан табылмады.');
      }
      savedId = id;
    }
    final savedProduct = Product(
      id: savedId,
      name: product.name,
      category: product.category,
      price: product.price,
      icon: product.icon,
      description: product.description,
      imageUrl: product.imageUrl,
    );
    final index = _products.indexWhere((item) => item.id == savedId);
    if (index == -1) {
      _products.add(savedProduct);
    } else {
      _products[index] = savedProduct;
    }
    notifyListeners();
  }

  Future<void> placeOrder({
    required String address,
    required String paymentMethod,
  }) async {
    if (_cart.isEmpty) {
      throw StateError('Себет бос болғандықтан тапсырыс рәсімделмейді.');
    }
    final itemCount = cartCount;
    final orderTotal = total;
    final createdAt = DateTime.now();
    final orderId = await _db.transaction((transaction) async {
      final id = await transaction.insert('orders', {
        'item_count': itemCount,
        'total': orderTotal,
        'address': address,
        'payment_method': paymentMethod,
        'created_at': createdAt.toIso8601String(),
      });
      for (final entry in _cart.entries) {
        final product = _productById(entry.key);
        await transaction.insert('order_items', {
          'order_id': id,
          'product_id': product.id,
          'product_name': product.name,
          'unit_price': product.price,
          'quantity': entry.value,
        });
      }
      await transaction.delete('cart_items');
      return id;
    });
    _orders.insert(
      0,
      ShopOrder(
        id: orderId,
        itemCount: itemCount,
        total: orderTotal,
        address: address,
        paymentMethod: paymentMethod,
        createdAt: createdAt,
      ),
    );
    _cart.clear();
    notifyListeners();
  }
}
