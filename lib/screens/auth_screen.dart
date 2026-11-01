import 'package:flutter/material.dart';

import '../services/shop_service.dart';

class AuthScreen extends StatefulWidget {
  final ShopService shop;
  final bool register;

  const AuthScreen({super.key, required this.shop, required this.register});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : 'Дұрыс email мекенжайын енгізіңіз';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = widget.register
        ? _name.text.trim()
        : _email.text.trim().split('@').first;
    widget.shop.authenticate(name);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.register ? 'Тіркелу сәтті аяқталды' : 'Жүйеге кірдіңіз',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.register ? 'Тіркелу' : 'Жүйеге кіру'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(22),
                  children: [
                    if (widget.register) ...[
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(labelText: 'Аты-жөні'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Атыңызды енгізіңіз'
                                : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Электрондық пошта',
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: [
                        widget.register
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: const InputDecoration(labelText: 'Құпиясөз'),
                      validator: (value) => value == null || value.length < 6
                          ? 'Құпиясөз кемінде 6 таңбадан тұруы керек'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _submit,
                      child: Text(widget.register ? 'Тіркелу' : 'Кіру'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/help'),
                      child: const Text('Құпиясөзді ұмыттыңыз ба?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
