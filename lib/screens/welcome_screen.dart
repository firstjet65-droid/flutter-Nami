import 'package:flutter/material.dart';

import '../services/shop_service.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';

class WelcomeScreen extends StatelessWidget {
  final ShopService shop;

  const WelcomeScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag,
                      size: 100,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'NAMI интернет-дүкені',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Қажетті тауарларды қарап, таңдаулыға сақтап, себетке қосыңыз.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => HomeShell(shop: shop),
                          ),
                        ),
                        child: const Text('Бастау'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
