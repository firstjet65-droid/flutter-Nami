import 'package:sqflite/sqflite.dart';

import '../models/api_product.dart';
import 'products_api.dart';
import 'shop_database.dart';

class ApiProductRepository {
  final ShopDatabase _database;
  final ProductsApi _api;

  ApiProductRepository({
    ShopDatabase? database,
    ProductsApi? api,
  })  : _database = database ?? ShopDatabase(),
        _api = api ?? ProductsApi();

  Future<List<ApiProduct>> getCachedProducts() async {
    final database = await _database.open();
    final rows = await database.query('api_products', orderBy: 'id');
    return rows.map(ApiProduct.fromMap).toList(growable: false);
  }

  Future<List<ApiProduct>> fetchProducts() async {
    final products = await _api.getProducts();
    final database = await _database.open();
    await database.transaction((transaction) async {
      await transaction.delete('api_products');
      final batch = transaction.batch();
      for (final product in products) {
        batch.insert(
          'api_products',
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
    return products;
  }

  Future<ApiProduct> createProduct(ApiProduct product) async {
    final savedProduct = await _api.createProduct(product);
    await _cacheProduct(savedProduct);
    return savedProduct;
  }

  Future<ApiProduct> updateProduct(ApiProduct product) async {
    final savedProduct = await _api.updateProduct(product);
    await _cacheProduct(savedProduct);
    return savedProduct;
  }

  Future<void> deleteProduct(int id) async {
    await _api.deleteProduct(id);
    final database = await _database.open();
    await database.delete('api_products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _cacheProduct(ApiProduct product) async {
    final database = await _database.open();
    await database.insert(
      'api_products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    _api.close();
    await _database.close();
  }
}
