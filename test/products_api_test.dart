import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:internet_duken/models/api_product.dart';
import 'package:internet_duken/screens/api_products_screen.dart';
import 'package:internet_duken/services/api_product_repository.dart';
import 'package:internet_duken/services/products_api.dart';
import 'package:internet_duken/services/shop_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('GET decodes products from the REST API', () async {
    final api = ProductsApi(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/products');
        expect(request.url.queryParameters['limit'], '30');
        return http.Response(
          jsonEncode({
            'products': [_serverProduct],
          }),
          200,
        );
      }),
    );

    final products = await api.getProducts();

    expect(products, hasLength(1));
    expect(products.single.title, 'Sample product');
    expect(products.single.price, 12.5);
    api.close();
  });

  test('POST sends a product and parses the server response', () async {
    final api = ProductsApi(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/products/add');
        expect(jsonDecode(request.body)['title'], 'New product');
        return http.Response(
          jsonEncode({..._serverProduct, 'id': 99, 'title': 'New product'}),
          201,
        );
      }),
    );

    final created =
        await api.createProduct(_product(id: 0, title: 'New product'));

    expect(created.id, 99);
    expect(created.title, 'New product');
    api.close();
  });

  test('PUT sends an update to the selected product endpoint', () async {
    final api = ProductsApi(
      client: MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/products/7');
        expect(jsonDecode(request.body)['title'], 'Updated product');
        return http.Response(
          jsonEncode({..._serverProduct, 'id': 7, 'title': 'Updated product'}),
          200,
        );
      }),
    );

    final updated =
        await api.updateProduct(_product(id: 7, title: 'Updated product'));

    expect(updated.title, 'Updated product');
    api.close();
  });

  test('DELETE sends request to the selected product endpoint', () async {
    final api = ProductsApi(
      client: MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/products/7');
        return http.Response('{"isDeleted":true,"id":7}', 200);
      }),
    );

    await expectLater(api.deleteProduct(7), completes);
    api.close();
  });

  test('non-success status and timeout are reported as API errors', () async {
    final failedApi = ProductsApi(
      client: MockClient((_) async => http.Response('{}', 503)),
    );
    await expectLater(
      failedApi.getProducts(),
      throwsA(isA<ProductsApiException>()),
    );
    failedApi.close();

    final timeoutApi = ProductsApi(
      client: MockClient(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 40));
          return http.Response('{"products":[]}', 200);
        },
      ),
      timeout: const Duration(milliseconds: 1),
    );
    await expectLater(
      timeoutApi.getProducts(),
      throwsA(isA<ProductsApiException>()),
    );
    timeoutApi.close();
  });

  test('connection failure is reported as an offline API error', () async {
    final api = ProductsApi(
      client: MockClient(
        (_) async => throw http.ClientException('Network unavailable'),
      ),
    );

    await expectLater(
      api.getProducts(),
      throwsA(
        isA<ProductsApiException>().having(
          (error) => error.message,
          'message',
          contains('Интернетке қосылу мүмкін болмады'),
        ),
      ),
    );
    api.close();
  });

  test('GET response is synchronized to the local SQLite cache', () async {
    final repository = ApiProductRepository(
      database: ShopDatabase(
        factory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      ),
      api: ProductsApi(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'products': [_serverProduct],
            }),
            200,
          ),
        ),
      ),
    );

    final remote = await repository.fetchProducts();
    final cached = await repository.getCachedProducts();

    expect(remote.single.id, 7);
    expect(cached.single.title, 'Sample product');
    await repository.close();
  });

  testWidgets('REST catalog displays server products in the interface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ApiProductsScreen(
          repository: _FakeApiProductRepository(
            const ApiProduct(
              id: 7,
              title: 'Sample product',
              description: 'Product description',
              category: 'accessories',
              price: 12.5,
              thumbnail: '',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sample product'), findsOneWidget);
    expect(find.textContaining('accessories'), findsOneWidget);
  });
}

const _serverProduct = <String, Object>{
  'id': 7,
  'title': 'Sample product',
  'description': 'Product description',
  'category': 'accessories',
  'price': 12.5,
  'thumbnail': 'https://example.com/image.png',
};

ApiProduct _product({required int id, required String title}) => ApiProduct(
      id: id,
      title: title,
      description: 'Product description',
      category: 'accessories',
      price: 12.5,
      thumbnail: 'https://example.com/image.png',
    );

class _FakeApiProductRepository implements ApiProductRepository {
  final ApiProduct product;

  _FakeApiProductRepository(this.product);

  @override
  Future<List<ApiProduct>> getCachedProducts() async => [];

  @override
  Future<List<ApiProduct>> fetchProducts() async => [product];

  @override
  Future<ApiProduct> createProduct(ApiProduct product) async => product;

  @override
  Future<ApiProduct> updateProduct(ApiProduct product) async => product;

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<void> close() async {}
}
