import 'package:flutter/material.dart';

import '../services/shop_service.dart';

class CheckoutScreen extends StatefulWidget {
  final ShopService shop;

  const CheckoutScreen({super.key, required this.shop});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  String _payment = 'Картамен';

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.shop.placeOrder(
      address: _address.text.trim(),
      paymentMethod: _payment,
    );
    Navigator.pushReplacementNamed(context, '/success');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Тапсырысты рәсімдеу')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Төлем бағасы: ${widget.shop.total} ₸',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _address,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Жеткізу мекенжайы',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Жеткізу мекенжайын енгізіңіз'
                              : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _payment,
                      decoration:
                          const InputDecoration(labelText: 'Төлем тәсілі'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Картамен',
                          child: Text('Картамен'),
                        ),
                        DropdownMenuItem(
                          value: 'Қолма-қол',
                          child: Text('Қолма-қол'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _payment = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Тапсырысты растау'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
