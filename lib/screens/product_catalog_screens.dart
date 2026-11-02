import 'package:flutter/material.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../services/shop_service.dart';
import '../widgets/product_card.dart';
import '../widgets/run_shop_action.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final ShopService shop;

  const HomeScreen({super.key, required this.shop});

  void _openProduct(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(shop: shop, product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = shop.products.take(4).toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 12, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Сәлем!'),
                      Text(
                        'Не іздеп жүрсіз?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Іздеу',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(shop: shop),
                    ),
                  ),
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  tooltip: 'Хабарламалар',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/notifications'),
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchEntry(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchScreen(shop: shop),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Санаттар',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoriesScreen(shop: shop),
                    ),
                  ),
                  child: const Text('Барлығын көру'),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: productCategories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(category),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductListScreen(
                              shop: shop,
                              category: category,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Танымал тауарлар',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(shop: shop),
                    ),
                  ),
                  child: const Text('Барлығы'),
                ),
              ],
            ),
          ),
        ),
        ProductGridSliver(
          shop: shop,
          items: featured,
          onOpen: (product) => _openProduct(context, product),
        ),
      ],
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  final ShopService shop;

  const CategoriesScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Санаттар')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: productCategories
                .map(
                  (category) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: Text(category),
                      subtitle: Text(
                        '${shop.products.where((p) => p.category == category).length} тауар',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            shop: shop,
                            category: category,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
}

class ProductListScreen extends StatelessWidget {
  final ShopService shop;
  final String? category;

  const ProductListScreen({super.key, required this.shop, this.category});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final items = shop.products
              .where(
                  (product) => category == null || product.category == category)
              .toList();
          return Scaffold(
            appBar: AppBar(title: Text(category ?? 'Барлық тауарлар')),
            body: items.isEmpty
                ? const Center(child: Text('Бұл санатта тауар жоқ.'))
                : ProductGrid(
                    shop: shop,
                    items: items,
                    onOpen: (product) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(shop: shop, product: product),
                      ),
                    ),
                  ),
          );
        },
      );
}

class SearchScreen extends StatefulWidget {
  final ShopService shop;

  const SearchScreen({super.key, required this.shop});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final items = widget.shop.products
        .where(
          (product) =>
              product.name.toLowerCase().contains(normalized) ||
              product.category.toLowerCase().contains(normalized),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Іздеу')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Тауар атауын немесе санатты енгізіңіз',
              ),
            ),
          ),
          Expanded(
            child: normalized.isNotEmpty && items.isEmpty
                ? const Center(child: Text('Тауар табылмады.'))
                : ProductGrid(
                    shop: widget.shop,
                    items: normalized.isEmpty ? const [] : items,
                    onOpen: (product) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          shop: widget.shop,
                          product: product,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class SearchEntry extends StatelessWidget {
  final VoidCallback onTap;

  const SearchEntry({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const IgnorePointer(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Тауар іздеу...',
            ),
          ),
        ),
      );
}

class ProductGrid extends StatelessWidget {
  final ShopService shop;
  final List<Product> items;
  final void Function(Product) onOpen;

  const ProductGrid({
    super.key,
    required this.shop,
    required this.items,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / 190).floor().clamp(1, 4);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductCard(
                product: product,
                onOpen: () => onOpen(product),
                onAdd: () => runShopAction(
                  context,
                  () => shop.addToCart(product),
                  successMessage: '${product.name} себетке қосылды',
                ),
                isFavorite: shop.favorites.contains(product.id),
                onFavorite: () => runShopAction(
                  context,
                  () => shop.toggleFavorite(product.id),
                ),
              );
            },
          );
        },
      );
}

class ProductGridSliver extends StatelessWidget {
  final ShopService shop;
  final List<Product> items;
  final void Function(Product) onOpen;

  const ProductGridSliver({
    super.key,
    required this.shop,
    required this.items,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = MediaQuery.sizeOf(context).width - 32;
          final columns = (width / 190).floor().clamp(1, 4);
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = items[index];
                  return ProductCard(
                    product: product,
                    onOpen: () => onOpen(product),
                    onAdd: () => runShopAction(
                      context,
                      () => shop.addToCart(product),
                      successMessage: '${product.name} себетке қосылды',
                    ),
                    isFavorite: shop.favorites.contains(product.id),
                    onFavorite: () => runShopAction(
                      context,
                      () => shop.toggleFavorite(product.id),
                    ),
                  );
                },
                childCount: items.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
            ),
          );
        },
      );
}
