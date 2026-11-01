import 'package:flutter/material.dart';

import '../services/shop_service.dart';
import '../theme/app_theme.dart';
import 'product_form_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ShopService shop;

  const ProfileScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: shop,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Менің профилім',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      shop.userName,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shop.signedIn ? 'NAMI пайдаланушысы' : 'Қонақ режимі',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (!shop.signedIn) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Жүйеге кіру'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Тіркелу'),
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: shop.signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Жүйеден шығу'),
                  ),
                ),
              const Text(
                'Аккаунт',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: const Text('Менің тапсырыстарым'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/orders'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('Хабарламалар'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, '/notifications'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Баптаулар'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Көмек'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/help'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Тауарлар',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.add_business_outlined),
                  title: const Text('Тауар қосу'),
                  subtitle: const Text('Жаңа тауарды каталогқа енгізу'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(shop: shop),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'NAMI © 2026',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      );
}
