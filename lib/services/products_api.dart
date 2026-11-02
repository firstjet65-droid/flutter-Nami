import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/api_product.dart';

class ProductsApiException implements Exception {
  final String message;

  const ProductsApiException(this.message);

  @override
  String toString() => message;
}

class ProductsApi {
  static final _baseUri = Uri.parse('https://dummyjson.com/products');
  final http.Client _client;
  final Duration timeout;

  ProductsApi({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  Future<List<ApiProduct>> getProducts() async {
    final response = await _send(() => _client.get(
          _baseUri.replace(queryParameters: {'limit': '30'}),
          headers: const {'Accept': 'application/json'},
        ));
    final payload = _decodeObject(response.body);
    final products = payload['products'];
    if (products is! List) {
      throw const ProductsApiException('Сервер тауарлар тізімін қайтармады.');
    }
    return products.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Тауар дерегінің форматы қате.');
      }
      return ApiProduct.fromJson(item);
    }).toList(growable: false);
  }

  Future<ApiProduct> createProduct(ApiProduct product) async {
    final response = await _send(() => _client.post(
          _baseUri.resolve('/products/add'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(product.toJson()),
        ));
    return ApiProduct.fromJson(_decodeObject(response.body));
  }

  Future<ApiProduct> updateProduct(ApiProduct product) async {
    final response = await _send(() => _client.put(
          _baseUri.resolve('/products/${product.id}'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(product.toJson()),
        ));
    return ApiProduct.fromJson(_decodeObject(response.body));
  }

  Future<void> deleteProduct(int id) async {
    await _send(() => _client.delete(_baseUri.resolve('/products/$id')));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProductsApiException(
          'Сервер қатесі: HTTP ${response.statusCode}.',
        );
      }
      return response;
    } on TimeoutException {
      throw const ProductsApiException(
        'Сервер ұзақ жауап берді. Интернетті тексеріп, қайта көріңіз.',
      );
    } on SocketException {
      throw const ProductsApiException(
        'Интернетке қосылу мүмкін болмады. Жергілікті сақталған деректер көрсетіледі.',
      );
    } on http.ClientException {
      throw const ProductsApiException(
        'Интернетке қосылу мүмкін болмады. Серверді немесе желіні тексеріңіз.',
      );
    } on FormatException catch (error) {
      throw ProductsApiException('Сервер дерегін оқу қатесі: ${error.message}');
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Сервер жауабы JSON объектісі емес.');
    }
    return decoded;
  }

  void close() => _client.close();
}
