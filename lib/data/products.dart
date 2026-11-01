import 'package:flutter/material.dart';

import '../models/product.dart';

const products = <Product>[
  Product(
    id: 1,
    name: 'Сымсыз құлаққап',
    category: 'Электроника',
    price: 12990,
    icon: Icons.headphones,
    description: 'Күнделікті қолдануға ыңғайлы сымсыз құлаққап.',
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: 2,
    name: 'Ақылды сағат',
    category: 'Электроника',
    price: 24990,
    icon: Icons.watch,
    description: 'Уақытты және белсенділікті бақылауға арналған сағат.',
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: 3,
    name: 'Спорттық аяқкиім',
    category: 'Киім',
    price: 18990,
    icon: Icons.directions_run,
    description: 'Жеңіл әрі ыңғайлы спорттық аяқкиім.',
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: 4,
    name: 'Қалаға арналған рюкзак',
    category: 'Аксессуарлар',
    price: 9990,
    icon: Icons.backpack,
    description: 'Күнделікті заттарды алып жүруге арналған рюкзак.',
    imageUrl:
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: 5,
    name: 'Үстел шамы',
    category: 'Үйге арналған',
    price: 7990,
    icon: Icons.light,
    description: 'Оқу мен жұмысқа арналған шағын үстел шамы.',
    imageUrl:
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=600&q=80',
  ),
  Product(
    id: 6,
    name: 'Bluetooth динамигі',
    category: 'Электроника',
    price: 15990,
    icon: Icons.speaker,
    description: 'Музыка тыңдауға арналған ықшам динамик.',
    imageUrl:
        'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=600&q=80',
  ),
];

const productCategories = [
  'Электроника',
  'Киім',
  'Аксессуарлар',
  'Үйге арналған',
];
