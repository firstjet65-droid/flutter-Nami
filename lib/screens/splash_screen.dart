import 'package:flutter/material.dart';

import '../services/shop_service.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final ShopService shop;

  const SplashScreen({super.key, required this.shop});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WelcomeScreen(shop: widget.shop),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                child: Icon(Icons.shopping_bag_outlined, size: 40),
              ),
              SizedBox(height: 14),
              Text(
                'NAMI',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Text('Сатып алу оңай әрі ыңғайлы'),
            ],
          ),
        ),
      );
}
