import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/shop_service.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final ShopService shop;

  const FavoritesScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final items = shop.products
              .where((product) => shop.favorites.contains(product.id))
              .toList();
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Таңдаулылар',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 85, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Таңдаулы тауарлар жоқ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ұнаған тауарды жүрек белгісімен сақтаңыз',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _FavoriteItem(
                      product: items[index],
                      onOpen: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(
                            shop: shop,
                            product: items[index],
                          ),
                        ),
                      ),
                      onRemove: () => shop.toggleFavorite(items[index].id),
                      onAdd: () {
                        shop.addToCart(items[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${items[index].name} себетке қосылды',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          );
        },
      );
}

class _FavoriteItem extends StatelessWidget {
  final Product product;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _FavoriteItem({
    required this.product,
    required this.onOpen,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 78,
                  height: 90,
                  child: product.imageUrl.isEmpty
                      ? Icon(product.icon, size: 45)
                      : Image.network(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              Icon(product.icon, size: 45),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${product.price} ₸',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text('Себетке қосу'),
                          ),
                          IconButton(
                            tooltip: 'Таңдаулыдан алып тастау',
                            onPressed: onRemove,
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
