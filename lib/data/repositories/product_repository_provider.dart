import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_repository_impl.dart';

/// Провайдер реализации репозитория.
/// Единственное место в проекте где data-слой «подключается» к domain-интерфейсу.
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(),
);
