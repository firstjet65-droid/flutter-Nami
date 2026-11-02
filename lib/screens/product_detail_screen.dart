import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/shop_service.dart';
import '../theme/app_theme.dart';
import '../widgets/run_shop_action.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ShopService shop;
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.shop,
    required this.product,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final currentProduct =
              shop.products.firstWhere((item) => item.id == product.id);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Тауар туралы'),
              actions: [
                IconButton(
                  tooltip: 'Тауарды өңдеу',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(
                          shop: shop, product: currentProduct),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: constraints.maxHeight * 0.42,
                            width: double.infinity,
                            child: currentProduct.imageUrl.isEmpty
                                ? _imageFallback()
                                : Image.network(
                                    currentProduct.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        _imageFallback(),
                                  ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            currentProduct.category,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentProduct.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${currentProduct.price} ₸',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentProduct.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              IconButton(
                                tooltip:
                                    shop.favorites.contains(currentProduct.id)
                                        ? 'Таңдаулыдан алып тастау'
                                        : 'Таңдаулыға қосу',
                                onPressed: () => runShopAction(
                                  context,
                                  () => shop.toggleFavorite(currentProduct.id),
                                ),
                                icon: Icon(
                                  shop.favorites.contains(currentProduct.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => runShopAction(
                                    context,
                                    () => shop.addToCart(currentProduct),
                                    successMessage: 'Тауар себетке қосылды',
                                  ),
                                  icon:
                                      const Icon(Icons.shopping_cart_outlined),
                                  label: const Text('Себетке қосу'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _imageFallback() => Center(
        child: Icon(product.icon, size: 150, color: AppTheme.primary),
      );
}
