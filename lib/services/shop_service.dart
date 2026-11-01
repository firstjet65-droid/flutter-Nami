import 'package:flutter/material.dart';

import '../data/products.dart' as catalog;
import '../models/product.dart';

class ShopService extends ChangeNotifier {
  final List<Product> _products = [...catalog.products];
  final Map<int, int> _cart = {};
  final Set<int> _favorites = {};
  final List<ShopOrder> _orders = [];

  bool _signedIn = false;
  String _userName = 'Қонақ';
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  int _nextProductId = 7;

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

  Product _productById(int id) =>
      _products.firstWhere((product) => product.id == id);

  void addToCart(Product product) {
    _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    notifyListeners();
  }

  void changeQuantity(int id, int delta) {
    final next = (_cart[id] ?? 0) + delta;
    if (next <= 0) {
      _cart.remove(id);
    } else {
      _cart[id] = next;
    }
    notifyListeners();
  }

  void toggleFavorite(int id) {
    if (!_favorites.add(id)) {
      _favorites.remove(id);
    }
    notifyListeners();
  }

  void authenticate(String name) {
    _signedIn = true;
    _userName = name;
    notifyListeners();
  }

  void signOut() {
    _signedIn = false;
    _userName = 'Қонақ';
    notifyListeners();
  }

  void setDarkMode(bool enabled) {
    _darkMode = enabled;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void saveProduct({
    int? id,
    required String name,
    required String category,
    required int price,
    required String description,
    required String imageUrl,
  }) {
    final product = Product(
      id: id ?? _nextProductId++,
      name: name,
      category: category,
      price: price,
      icon: Icons.shopping_bag_outlined,
      description: description,
      imageUrl: imageUrl,
    );
    final index = _products.indexWhere((item) => item.id == id);
    if (index == -1) {
      _products.add(product);
    } else {
      _products[index] = product;
    }
    notifyListeners();
  }

  void placeOrder({
    required String address,
    required String paymentMethod,
  }) {
    if (_cart.isEmpty) {
      throw StateError('Себет бос болғандықтан тапсырыс рәсімделмейді.');
    }
    _orders.insert(
      0,
      ShopOrder(
        itemCount: cartCount,
        total: total,
        address: address,
        paymentMethod: paymentMethod,
      ),
    );
    _cart.clear();
    notifyListeners();
  }
}
