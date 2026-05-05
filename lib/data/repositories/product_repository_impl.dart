import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/remote_product_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteProductDataSource _remote;

  ProductRepositoryImpl({RemoteProductDataSource? remote})
      : _remote = remote ?? RemoteProductDataSource();

  @override
  Future<List<Product>> fetchProducts() => _remote.fetchGroceries();
}
