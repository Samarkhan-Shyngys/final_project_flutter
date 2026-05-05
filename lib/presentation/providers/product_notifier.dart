import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart' show kProducts;

// ── State ─────────────────────────────────────────────────────────────────────

enum ProductLoadStatus { initial, loading, success, failure }

class ProductState {
  final List<Product> products;
  final ProductLoadStatus status;
  final String? error;

  const ProductState({
    this.products = kProducts,
    this.status = ProductLoadStatus.initial,
    this.error,
  });

  bool get isLoading => status == ProductLoadStatus.loading;
  bool get hasError  => status == ProductLoadStatus.failure;

  ProductState copyWith({
    List<Product>? products,
    ProductLoadStatus? status,
    String? error,
  }) =>
      ProductState(
        products: products ?? this.products,
        status: status ?? this.status,
        error: error,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _repo;

  ProductNotifier(this._repo) : super(const ProductState());

  Future<void> loadFromApi() async {
    state = state.copyWith(status: ProductLoadStatus.loading);
    try {
      final products = await _repo.fetchProducts();
      state = state.copyWith(
        products: products,
        status: ProductLoadStatus.success,
      );
    } catch (e) {
      // При ошибке оставляем локальные продукты — offline-first
      state = state.copyWith(
        status: ProductLoadStatus.failure,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(ProductRepositoryImpl()),
);
