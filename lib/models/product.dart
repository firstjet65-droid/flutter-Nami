import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final String description;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.description,
    this.imageUrl = '',
  });
}

class ShopOrder {
  final int itemCount;
  final int total;
  final String address;
  final String paymentMethod;

  const ShopOrder({
    required this.itemCount,
    required this.total,
    required this.address,
    required this.paymentMethod,
  });
}
