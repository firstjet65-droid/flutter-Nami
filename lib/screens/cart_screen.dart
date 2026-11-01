import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/shop_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final ShopService shop;

  const CartScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          final items = shop.products
              .where((product) => shop.cart.containsKey(product.id))
              .toList();
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Менің себетім',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: items.isEmpty
                ? const _EmptyCart()
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) => _CartItem(
                            product: items[index],
                            quantity: shop.cart[items[index].id]!,
                            onChange: (delta) =>
                                shop.changeQuantity(items[index].id, delta),
                          ),
                        ),
                      ),
                      _CartSummary(
                        total: shop.total,
                        onCheckout: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(shop: shop),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 85, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Себетіңіз әзірге бос',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Ұнаған тауарларыңызды себетке қосыңыз'),
          ],
        ),
      );
}

class _CartItem extends StatelessWidget {
  final Product product;
  final int quantity;
  final ValueChanged<int> onChange;

  const _CartItem({
    required this.product,
    required this.quantity,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 82,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${product.price} ₸',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Санын азайту',
                          onPressed: () => onChange(-1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$quantity'),
                        IconButton(
                          tooltip: 'Санын көбейту',
                          onPressed: () => onChange(1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _CartSummary extends StatelessWidget {
  final int total;
  final VoidCallback onCheckout;

  const _CartSummary({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Жалпы бағасы', style: TextStyle(fontSize: 17)),
                Text(
                  '$total ₸',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCheckout,
                child: const Text('Тапсырыс рәсімдеу'),
              ),
            ),
          ],
        ),
      );
}
