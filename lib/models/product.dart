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
  final int id;
  final int itemCount;
  final int total;
  final String address;
  final String paymentMethod;
  final DateTime createdAt;

  const ShopOrder({
    required this.id,
    required this.itemCount,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
  });
}

class ShopOrderItem {
  final int productId;
  final String productName;
  final int unitPrice;
  final int quantity;

  const ShopOrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });
}
