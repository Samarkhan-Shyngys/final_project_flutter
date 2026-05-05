import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/product.dart';
import '../../providers/cart_notifier.dart';
import '../../providers/product_notifier.dart';
import '../../widgets/quantity_stepper.dart';

class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  ConsumerState<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  String _search = '';
  String _category = 'all';
  final _searchController = TextEditingController();

  static const _categories = [
    ('all', 'Все'),
    ('vegetables', '🥕 Овощи'),
    ('fruits', '🍎 Фрукты'),
    ('supplies', '🧹 Хозтовары'),
  ];

  List<Product> _filtered(List<Product> products) {
    return products.where((p) {
      final matchCat = _category == 'all' || p.category == _category;
      final matchSearch = _search.isEmpty || p.name.toLowerCase().contains(_search.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Загружаем продукты с API при первом открытии
    Future.microtask(() => ref.read(productProvider.notifier).loadFromApi());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final productState = ref.watch(productProvider);
    final filtered = _filtered(productState.products);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            _buildHeader(context, cart, productState),
            Expanded(
              child: Stack(
                children: [
                  if (productState.isLoading && productState.status == ProductLoadStatus.loading
                      && productState.products == kProducts)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else
                    ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(scrollbars: false),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          top: 12,
                          bottom: cart.totalItems > 0 ? 96 : 24,
                          left: 20,
                          right: 20,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          final qty = cart.getQuantity(product.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ProductCard(
                              product: product,
                              quantity: qty,
                              onAdd: () => ref.read(cartProvider.notifier).addItem(product),
                              onChanged: (val) => ref.read(cartProvider.notifier).updateQuantity(product.id, val),
                            ),
                          );
                        },
                      ),
                    ),
                  if (cart.totalItems > 0)
                    Positioned(
                      bottom: 20, left: 20, right: 20,
                      child: _FloatingCartButton(
                        totalItems: cart.totalItems,
                        onTap: () => context.go('/manager/cart'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartState cart, ProductState productState) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статус-баннер API
          if (productState.isLoading)
            _ApiStatusBanner(
              icon: Icons.cloud_download_outlined,
              color: AppColors.adminBlue,
              bg: AppColors.adminBlueLight,
              text: 'Загрузка каталога с сервера...',
              trailing: const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.adminBlue),
              ),
            )
          else if (productState.hasError)
            _ApiStatusBanner(
              icon: Icons.wifi_off_rounded,
              color: const Color(0xFFB91C1C),
              bg: const Color(0xFFFEE2E2),
              text: 'Офлайн: ${productState.error}',
              trailing: GestureDetector(
                onTap: () => ref.read(productProvider.notifier).loadFromApi(),
                child: const Text('Повторить',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C))),
              ),
            )
          else if (productState.status == ProductLoadStatus.success)
            _ApiStatusBanner(
              icon: Icons.cloud_done_rounded,
              color: AppColors.primary,
              bg: AppColors.primaryLight,
              text: 'Каталог загружен: ${productState.products.length} позиций',
            ),
          if (productState.status != ProductLoadStatus.initial) const SizedBox(height: 10),
          Row(
            children: [
              const Text('Каталог',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/manager/cart'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                    ),
                  ),
                  if (cart.totalItems > 0)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${cart.totalItems}',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: AppColors.textLight, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      hintText: 'Поиск товаров...',
                      hintStyle: TextStyle(fontSize: 14, color: AppColors.textLight),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 14, color: AppColors.text),
                  ),
                ),
                const Icon(Icons.tune, color: AppColors.textLight, size: 20),
                const SizedBox(width: 12),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isActive = _category == cat.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _category = cat.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          cat.$2,
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final ValueChanged<int> onChanged;

  const _ProductCard({
    required this.product, required this.quantity,
    required this.onAdd, required this.onChanged,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final inCart = widget.quantity > 0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: inCart ? Border.all(color: AppColors.primary, width: 1.5) : null,
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(widget.product.emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text('от ${widget.product.minOrder} ${widget.product.unit}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text('${widget.product.price.toInt()} ₸ / ${widget.product.unit}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (widget.quantity == 0)
                GestureDetector(
                  onTap: widget.onAdd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: const Text('+ Добавить',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                )
              else
                QuantityStepper(
                  quantity: widget.quantity,
                  minOrder: widget.product.minOrder,
                  onChanged: widget.onChanged,
                  size: StepperSize.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingCartButton extends StatefulWidget {
  final int totalItems;
  final VoidCallback onTap;

  const _FloatingCartButton({required this.totalItems, required this.onTap});

  @override
  State<_FloatingCartButton> createState() => _FloatingCartButtonState();
}

class _FloatingCartButtonState extends State<_FloatingCartButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x661A6B4A), blurRadius: 16, offset: Offset(0, 4))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Перейти в корзину',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('${widget.totalItems} поз.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── API Status Banner ─────────────────────────────────────────────────────────

class _ApiStatusBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String text;
  final Widget? trailing;

  const _ApiStatusBanner({
    required this.icon,
    required this.color,
    required this.bg,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
                overflow: TextOverflow.ellipsis),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
