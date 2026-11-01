import 'package:flutter/material.dart';

import '../services/shop_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final ShopService shop;

  const SettingsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Баптаулар')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Қараңғы тақырып'),
                  subtitle: const Text('Қосымшаның түс көрінісін өзгерту'),
                  value: shop.darkMode,
                  onChanged: shop.setDarkMode,
                ),
              ),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Хабарландырулар'),
                  value: shop.notificationsEnabled,
                  onChanged: shop.setNotificationsEnabled,
                ),
              ),
            ],
          ),
        ),
      );
}

class OrdersScreen extends StatelessWidget {
  final ShopService shop;

  const OrdersScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Менің тапсырыстарым')),
          body: shop.orders.isEmpty
              ? const MessageBody(
                  message: 'Сізде әзірге тапсырыс жоқ.',
                  icon: Icons.receipt_long,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shop.orders.length,
                  itemBuilder: (context, index) {
                    final order = shop.orders[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: Text('${order.total} ₸'),
                        subtitle: Text(
                          '${order.itemCount} тауар · ${order.paymentMethod}\n${order.address}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      );
}

class MessageScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const MessageScreen({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: MessageBody(message: message, icon: icon),
      );
}

class MessageBody extends StatelessWidget {
  final String message;
  final IconData icon;

  const MessageBody({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 70, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      );
}
