import 'package:flutter/material.dart';

import '../models/api_product.dart';
import '../services/api_product_repository.dart';

class ApiProductsScreen extends StatefulWidget {
  final ApiProductRepository? repository;

  const ApiProductsScreen({super.key, this.repository});

  @override
  State<ApiProductsScreen> createState() => _ApiProductsScreenState();
}

class _ApiProductsScreenState extends State<ApiProductsScreen> {
  late final ApiProductRepository _repository;
  late final bool _ownsRepository;
  List<ApiProduct> _products = [];
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? ApiProductRepository();
    _loadProducts();
  }

  @override
  void dispose() {
    if (_ownsRepository) {
      _repository.close();
    }
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cached = await _repository.getCachedProducts();
      if (!mounted) return;
      if (cached.isNotEmpty) {
        setState(() => _products = cached);
      }
      final remote = await _repository.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = remote;
        _error = null;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProduct(ApiProduct product) async {
    setState(() => _busy = true);
    try {
      final isNew = product.id == 0;
      final saved = isNew
          ? await _repository.createProduct(product)
          : await _repository.updateProduct(product);
      if (!mounted) return;
      setState(() {
        _products = [
          for (final item in _products)
            if (item.id != saved.id) item,
          saved,
        ]..sort((a, b) => a.id.compareTo(b.id));
        _error = null;
      });
      _showMessage(isNew ? 'Тауар серверге жіберілді' : 'Тауар жаңартылды');
    } on Exception catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteProduct(ApiProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тауарды жою'),
        content: Text('"${product.title}" тауарын жоясыз ба?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Жою'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await _repository.deleteProduct(product.id);
      if (!mounted) return;
      setState(() {
        _products.removeWhere((item) => item.id == product.id);
        _error = null;
      });
      _showMessage('Тауар серверден жойылды');
    } on Exception catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openForm([ApiProduct? product]) async {
    final result = await showDialog<ApiProduct>(
      context: context,
      builder: (_) => _ApiProductFormDialog(product: product),
    );
    if (result != null) await _saveProduct(result);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('REST API каталогы'),
          actions: [
            IconButton(
              tooltip: 'Қайта жүктеу',
              onPressed: _loading || _busy ? null : _loadProducts,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _busy ? null : () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Тауар қосу'),
        ),
        body: Column(
          children: [
            const _DemoApiNotice(),
            if (_busy || _loading) const LinearProgressIndicator(),
            if (_error != null) _ErrorBanner(message: _error!),
            Expanded(
              child: _loading && _products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? _EmptyApiProducts(onRetry: _loadProducts)
                      : RefreshIndicator(
                          onRefresh: _loadProducts,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return _ApiProductCard(
                                product: product,
                                enabled: !_busy,
                                onEdit: () => _openForm(product),
                                onDelete: () => _deleteProduct(product),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      );
}

class _DemoApiNotice extends StatelessWidget {
  const _DemoApiNotice();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: const Text(
          'Демо API: сұраулар серверге жіберіледі, бірақ DummyJSON өзгерістерді тұрақты сақтамайды. Соңғы алынған каталог SQLite кэшінде сақталады.',
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_outlined),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
}

class _EmptyApiProducts extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyApiProducts({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 56),
              const SizedBox(height: 12),
              const Text('Каталогта әзірге тауар жоқ.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Қайта жүктеу'),
              ),
            ],
          ),
        ),
      );
}

class _ApiProductCard extends StatelessWidget {
  final ApiProduct product;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ApiProductCard({
    required this.product,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: SizedBox(
            width: 64,
            height: 64,
            child: product.thumbnail.isEmpty
                ? const Icon(Icons.image_not_supported_outlined, size: 36)
                : Image.network(
                    product.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 36),
                  ),
          ),
          title:
              Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${product.category} · \$${product.price.toStringAsFixed(2)}\n${product.description}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          trailing: PopupMenuButton<String>(
            enabled: enabled,
            onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Өңдеу')),
              PopupMenuItem(value: 'delete', child: Text('Жою')),
            ],
          ),
        ),
      );
}

class _ApiProductFormDialog extends StatefulWidget {
  final ApiProduct? product;

  const _ApiProductFormDialog({this.product});

  @override
  State<_ApiProductFormDialog> createState() => _ApiProductFormDialogState();
}

class _ApiProductFormDialogState extends State<_ApiProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _category;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late final TextEditingController _thumbnail;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _title = TextEditingController(text: product?.title ?? '');
    _category = TextEditingController(text: product?.category ?? '');
    _price = TextEditingController(text: product?.price.toString() ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    _thumbnail = TextEditingController(text: product?.thumbnail ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _price.dispose();
    _description.dispose();
    _thumbnail.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ApiProduct(
        id: widget.product?.id ?? 0,
        title: _title.text.trim(),
        category: _category.text.trim(),
        price: double.parse(_price.text.trim()),
        description: _description.text.trim(),
        thumbnail: _thumbnail.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.product == null ? 'Жаңа тауар' : 'Тауарды өңдеу'),
        content: SizedBox(
          width: 480,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _requiredField(_title, 'Атауы'),
                  _requiredField(_category, 'Санаты'),
                  TextFormField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Бағасы (USD)'),
                    validator: (value) {
                      final price = double.tryParse(value?.trim() ?? '');
                      return price == null || price <= 0
                          ? 'Оң сан енгізіңіз'
                          : null;
                    },
                  ),
                  _requiredField(_description, 'Сипаттамасы', maxLines: 3),
                  TextFormField(
                    controller: _thumbnail,
                    decoration: const InputDecoration(
                        labelText: 'Сурет URL (міндетті емес)'),
                    validator: (value) {
                      final url = value?.trim() ?? '';
                      if (url.isEmpty) return null;
                      final uri = Uri.tryParse(url);
                      return uri != null &&
                              (uri.scheme == 'https' || uri.scheme == 'http') &&
                              uri.host.isNotEmpty
                          ? null
                          : 'Дұрыс http немесе https сілтемесін енгізіңіз';
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            onPressed: _submit,
            child: const Text('Сақтау'),
          ),
        ],
      );

  Widget _requiredField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: controller,
        minLines: maxLines == 1 ? null : maxLines,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value == null || value.trim().isEmpty
            ? '$label өрісін толтырыңыз'
            : null,
      );
}
