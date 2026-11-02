import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_duken/data/products.dart';
import 'package:internet_duken/screens/auth_screen.dart';
import 'package:internet_duken/screens/home_shell.dart';
import 'package:internet_duken/screens/order_success_screen.dart';
import 'package:internet_duken/screens/product_catalog_screens.dart';
import 'package:internet_duken/screens/static_screens.dart';
import 'package:internet_duken/services/shop_database.dart';
import 'package:internet_duken/services/shop_service.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  Future<ShopService> createShop({
    String? databasePath,
    WidgetTester? tester,
  }) async {
    Future<ShopService> openShop() async {
      final shop = ShopService(
        database: ShopDatabase(
          factory: databaseFactoryFfi,
          databasePath: databasePath ?? inMemoryDatabasePath,
        ),
      );
      await shop.initialize();
      return shop;
    }

    if (tester == null) return openShop();
    return await tester.runAsync(openShop) ??
        (throw StateError('Could not initialize test database.'));
  }

  Future<void> waitForShop(
    WidgetTester tester,
    bool Function() condition,
  ) async {
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!condition()) {
        if (DateTime.now().isAfter(deadline)) {
          throw TimeoutException('Shop state did not update.');
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
  }

  testWidgets('Home supports cart checkout and order history', (
    tester,
  ) async {
    final shop = await createShop(tester: tester);
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(shop: shop),
        routes: {
          '/home': (_) => HomeShell(shop: shop),
          '/success': (_) => const OrderSuccessScreen(),
          '/orders': (_) => OrdersScreen(shop: shop),
        },
      ),
    );
    expect(find.text('Не іздеп жүрсіз?'), findsOneWidget);
    expect(find.text('Танымал тауарлар'), findsOneWidget);

    final addToCart = find.byTooltip('Себетке қосу').first;
    await tester.ensureVisible(addToCart);
    await tester.pumpAndSettle();
    await tester.tap(addToCart);
    await waitForShop(tester, () => shop.cartCount == 1);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Себет (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Жалпы бағасы'), findsOneWidget);

    await tester.tap(find.text('Тапсырыс рәсімдеу'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Астана');
    await tester.tap(find.text('Тапсырысты растау'));
    await waitForShop(tester, () => shop.orders.isNotEmpty);
    await tester.pumpAndSettle();
    expect(find.text('Тапсырыс қабылданды!'), findsOneWidget);

    await tester.tap(find.text('Дүкенге оралу'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.text('Менің профилім'), findsOneWidget);
    await tester.tap(find.text('Менің тапсырыстарым'));
    await tester.pumpAndSettle();
    expect(find.text('12990 ₸'), findsOneWidget);
    await tester.runAsync(shop.close);
  });

  testWidgets('Search filters products by name', (tester) async {
    final shop = await createShop(tester: tester);
    await tester.pumpWidget(
      MaterialApp(home: SearchScreen(shop: shop)),
    );
    await tester.enterText(find.byType(TextField), 'сағат');
    await tester.pump();
    expect(find.text('Ақылды сағат'), findsOneWidget);
    expect(find.text('Спорттық аяқкиім'), findsNothing);
    await tester.runAsync(shop.close);
  });

  testWidgets('Login form displays validation messages', (tester) async {
    final shop = await createShop(tester: tester);
    await tester.pumpWidget(
      MaterialApp(home: AuthScreen(shop: shop, register: false)),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'bad-email');
    await tester.enterText(fields.at(1), '123');
    await tester.tap(find.text('Кіру'));
    await tester.pump();
    expect(find.text('Дұрыс email мекенжайын енгізіңіз'), findsOneWidget);
    expect(
      find.text('Құпиясөз кемінде 6 таңбадан тұруы керек'),
      findsOneWidget,
    );
    expect(shop.signedIn, isFalse);
    await tester.runAsync(shop.close);
  });

  testWidgets('Home adapts to a narrow phone layout', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    final shop = await createShop(tester: tester);
    await tester.pumpWidget(MaterialApp(home: HomeShell(shop: shop)));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Не іздеп жүрсіз?'), findsOneWidget);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.runAsync(shop.close);
  });

  test('SQLite persists products, cart, favorites, settings, and orders',
      () async {
    final directory = await Directory.systemTemp.createTemp('nami-sqlite-');
    final databasePath = path.join(directory.path, 'shop_test.db');
    final shop = await createShop(databasePath: databasePath);
    final product = products.first;

    await shop.addToCart(product);
    await shop.addToCart(product);
    expect(shop.cartCount, 2);
    expect(shop.total, product.price * 2);

    await shop.changeQuantity(product.id, -1);
    expect(shop.cartCount, 1);
    await shop.toggleFavorite(product.id);
    expect(shop.favorites.contains(product.id), isTrue);
    await shop.setDarkMode(true);
    await shop.setNotificationsEnabled(false);

    await shop.saveProduct(
      id: product.id,
      name: 'Өңделген тауар',
      category: product.category,
      price: 5000,
      description: 'Жаңартылған сипаттама',
      imageUrl: '',
    );
    expect(shop.products.first.name, 'Өңделген тауар');

    await shop.placeOrder(address: 'Астана', paymentMethod: 'Картамен');
    expect(shop.cartCount, 0);
    expect(shop.orders, hasLength(1));
    expect(shop.orders.first.address, 'Астана');
    await shop.close();

    final restored = await createShop(databasePath: databasePath);
    expect(restored.products.first.name, 'Өңделген тауар');
    expect(restored.cartCount, 0);
    expect(restored.favorites, contains(product.id));
    expect(restored.darkMode, isTrue);
    expect(restored.notificationsEnabled, isFalse);
    expect(restored.orders, hasLength(1));
    expect(restored.orders.first.total, 5000);
    await restored.close();
    await directory.delete(recursive: true);
  });
}
