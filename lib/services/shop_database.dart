import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../data/products.dart';

class ShopDatabase {
  final DatabaseFactory? _factory;
  final String? _databasePath;
  Database? _database;

  ShopDatabase({DatabaseFactory? factory, String? databasePath})
      : _factory = factory,
        _databasePath = databasePath;

  Future<Database> open() async {
    if (_database != null) return _database!;
    final databasePath = _databasePath ??
        (kIsWeb
            ? 'nami_shop.db'
            : path.join(await getDatabasesPath(), 'nami_shop.db'));
    final options = OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createSchema,
      onUpgrade: _upgradeSchema,
    );
    _database = _factory == null
        ? await openDatabase(databasePath, options: options)
        : await _factory.openDatabase(databasePath, options: options);
    return _database!;
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    if (database != null && database.isOpen) {
      await database.close();
    }
  }

  Future<void> _createSchema(Database database, int version) async {
    await database.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price INTEGER NOT NULL CHECK (price > 0),
        icon_key TEXT NOT NULL,
        description TEXT NOT NULL,
        image_url TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE cart_items (
        product_id INTEGER PRIMARY KEY,
        quantity INTEGER NOT NULL CHECK (quantity > 0),
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await database.execute('''
      CREATE TABLE favorites (
        product_id INTEGER PRIMARY KEY,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await database.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_count INTEGER NOT NULL,
        total INTEGER NOT NULL,
        address TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        unit_price INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
    await database.execute('''
      CREATE TABLE app_settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
      )
    ''');
    await _createApiProductsTable(database);
    final batch = database.batch();
    for (final product in products) {
      batch.insert('products', {
        'id': product.id,
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'icon_key': _iconKey(product.icon),
        'description': product.description,
        'image_url': product.imageUrl,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> _upgradeSchema(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createApiProductsTable(database);
    }
  }

  Future<void> _createApiProductsTable(Database database) =>
      database.execute('''
    CREATE TABLE api_products (
      id INTEGER PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      price REAL NOT NULL,
      thumbnail TEXT NOT NULL
    )
  ''');

  String _iconKey(IconData icon) {
    if (icon == Icons.headphones) return 'headphones';
    if (icon == Icons.watch) return 'watch';
    if (icon == Icons.directions_run) return 'directions_run';
    if (icon == Icons.backpack) return 'backpack';
    if (icon == Icons.light) return 'light';
    if (icon == Icons.speaker) return 'speaker';
    return 'shopping_bag_outlined';
  }
}
