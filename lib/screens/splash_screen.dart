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
  Object? _databaseError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeAndContinue();
  }

  Future<void> _initializeAndContinue() async {
    try {
      await widget.shop.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => WelcomeScreen(shop: widget.shop)),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _databaseError = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _databaseError;
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'SQLite дерекқорын ашу мүмкін болмады.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _databaseError = null;
                    });
                    _initializeAndContinue();
                  },
                  child: const Text('Қайта көру'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 38,
              child: Icon(Icons.shopping_bag_outlined, size: 40),
            ),
            const SizedBox(height: 14),
            const Text(
              'NAMI',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Text('Сатып алу оңай әрі ыңғайлы'),
            if (_loading) ...[
              const SizedBox(height: 18),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
