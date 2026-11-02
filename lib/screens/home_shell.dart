import 'package:flutter/material.dart';

import '../services/shop_service.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'product_catalog_screens.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  final ShopService shop;

  const HomeShell({super.key, required this.shop});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.shop,
        builder: (context, _) => Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: selectedTab,
              children: [
                HomeScreen(shop: widget.shop),
                CartScreen(shop: widget.shop),
                FavoritesScreen(shop: widget.shop),
                ProfileScreen(shop: widget.shop),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedTab,
            onDestinationSelected: (index) =>
                setState(() => selectedTab = index),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Басты ',
              ),
              NavigationDestination(
                icon: const Icon(Icons.shopping_cart_outlined),
                label:
                    'Себет${widget.shop.cartCount > 0 ? ' (${widget.shop.cartCount})' : ''}',
              ),
              const NavigationDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: 'Таңдаулы',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                label: 'Профиль',
              ),
            ],
          ),
        ),
      );
}
