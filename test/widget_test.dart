import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_duken/app.dart';
import 'package:internet_duken/data/products.dart';
import 'package:internet_duken/screens/auth_screen.dart';
import 'package:internet_duken/screens/home_shell.dart';
import 'package:internet_duken/screens/product_catalog_screens.dart';
import 'package:internet_duken/services/shop_service.dart';

void main() {
  testWidgets('Splash opens the NAMI welcome screen and home', (
    tester,
  ) async {
    await tester.pumpWidget(const ShopApp());
    expect(find.text('NAMI'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.text('NAMI интернет-дүкені'), findsOneWidget);

    await tester.tap(find.text('Бастау'));
    await tester.pumpAndSettle();
    expect(find.text('Не іздеп жүрсіз?'), findsOneWidget);
    expect(find.text('Танымал тауарлар'), findsOneWidget);

    final addToCart = find.byTooltip('Себетке қосу').first;
    await tester.ensureVisible(addToCart);
    await tester.pumpAndSettle();
    await tester.tap(addToCart);
    await tester.pump();
    await tester.tap(find.text('Себет (1)'));
    await tester.pump();
    expect(find.text('Жалпы бағасы'), findsOneWidget);

    await tester.tap(find.text('Тапсырыс рәсімдеу'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Астана');
    await tester.tap(find.text('Тапсырысты растау'));
    await tester.pumpAndSettle();
    expect(find.text('Тапсырыс қабылданды!'), findsOneWidget);

    await tester.tap(find.text('Дүкенге оралу'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль'));
    await tester.pump();
    expect(find.text('Менің профилім'), findsOneWidget);
    await tester.tap(find.text('Менің тапсырыстарым'));
    await tester.pumpAndSettle();
    expect(find.text('12990 ₸'), findsOneWidget);
  });

  testWidgets('Search filters products by name', (tester) async {
    final shop = ShopService();
    await tester.pumpWidget(
      MaterialApp(home: SearchScreen(shop: shop)),
    );
    await tester.enterText(find.byType(TextField), 'сағат');
    await tester.pump();
    expect(find.text('Ақылды сағат'), findsOneWidget);
    expect(find.text('Спорттық аяқкиім'), findsNothing);
    shop.dispose();
  });

  testWidgets('Login form displays validation messages', (tester) async {
    final shop = ShopService();
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
    shop.dispose();
  });

  testWidgets('Home adapts to a narrow phone layout', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    final shop = ShopService();
    await tester.pumpWidget(MaterialApp(home: HomeShell(shop: shop)));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Не іздеп жүрсіз?'), findsOneWidget);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    shop.dispose();
  });

  test('Cart, favorites, product editing, and checkout state work', () {
    final shop = ShopService();
    final product = products.first;

    shop.addToCart(product);
    shop.addToCart(product);
    expect(shop.cartCount, 2);
    expect(shop.total, product.price * 2);

    shop.changeQuantity(product.id, -1);
    expect(shop.cartCount, 1);
    shop.toggleFavorite(product.id);
    expect(shop.favorites.contains(product.id), isTrue);
    shop.toggleFavorite(product.id);
    expect(shop.favorites.contains(product.id), isFalse);

    shop.saveProduct(
      id: product.id,
      name: 'Өңделген тауар',
      category: product.category,
      price: 5000,
      description: 'Жаңартылған сипаттама',
      imageUrl: '',
    );
    expect(shop.products.first.name, 'Өңделген тауар');

    shop.placeOrder(address: 'Астана', paymentMethod: 'Картамен');
    expect(shop.cartCount, 0);
    expect(shop.orders, hasLength(1));
    expect(shop.orders.first.address, 'Астана');
    shop.dispose();
  });
}
