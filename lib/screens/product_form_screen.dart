import 'package:flutter/material.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../services/shop_service.dart';

class ProductFormScreen extends StatefulWidget {
  final ShopService shop;
  final Product? product;

  const ProductFormScreen({super.key, required this.shop, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late final TextEditingController _imageUrl;
  late String _category;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    _price = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _description = TextEditingController(text: product?.description ?? '');
    _imageUrl = TextEditingController(text: product?.imageUrl ?? '');
    _category = product?.category ?? productCategories.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.shop.saveProduct(
      id: widget.product?.id,
      name: _name.text.trim(),
      category: _category,
      price: int.parse(_price.text.trim()),
      description: _description.text.trim(),
      imageUrl: _imageUrl.text.trim(),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.product == null
            ? 'Тауар каталогқа қосылды'
            : 'Тауар ақпараты сақталды'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.product == null ? 'Тауар қосу' : 'Тауарды өңдеу'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration:
                          const InputDecoration(labelText: 'Тауар атауы'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Тауар атауын енгізіңіз'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Санат'),
                      items: productCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _category = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Бағасы'),
                      validator: (value) {
                        final price = int.tryParse(value?.trim() ?? '');
                        return price == null || price <= 0
                            ? 'Бағаны бүтін оң санмен енгізіңіз'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _description,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Сипаттамасы',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Тауар сипаттамасын енгізіңіз'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageUrl,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Сурет сілтемесі (міндетті емес)',
                      ),
                      validator: (value) {
                        final url = value?.trim() ?? '';
                        if (url.isEmpty) return null;
                        final uri = Uri.tryParse(url);
                        return uri != null &&
                                (uri.scheme == 'https' ||
                                    uri.scheme == 'http') &&
                                uri.host.isNotEmpty
                            ? null
                            : 'Сурет сілтемесі http:// немесе https:// арқылы басталуы керек';
                      },
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _save,
                      child: const Text('Сақтау'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
