import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'screens/order_success_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/static_screens.dart';
import 'services/shop_service.dart';
import 'theme/app_theme.dart';

class ShopApp extends StatefulWidget {
  const ShopApp({super.key});

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late final ShopService shop;

  @override
  void initState() {
    super.initState();
    shop = ShopService();
  }

  @override
  void dispose() {
    shop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NAMI',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: shop.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(shop: shop),
          routes: {
            '/home': (_) => HomeShell(shop: shop),
            '/login': (_) => AuthScreen(shop: shop, register: false),
            '/register': (_) => AuthScreen(shop: shop, register: true),
            '/settings': (_) => SettingsScreen(shop: shop),
            '/orders': (_) => OrdersScreen(shop: shop),
            '/notifications': (_) => const MessageScreen(
                  title: 'Хабарламалар',
                  message: 'Әзірге жаңа хабарлама жоқ.',
                  icon: Icons.notifications_none,
                ),
            '/help': (_) => const MessageScreen(
                  title: 'Көмек',
                  message:
                      'Сұрақтарыңыз болса, support@nami.kz мекенжайына жазыңыз.',
                  icon: Icons.help_outline,
                ),
            '/product/create': (_) => ProductFormScreen(shop: shop),
            '/success': (_) => const OrderSuccessScreen(),
          },
        ),
      );
}
