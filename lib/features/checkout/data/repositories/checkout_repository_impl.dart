import 'package:dartz/dartz.dart' hide Order;
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';
import 'package:shopease/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Order>> placeOrder(Order order, String uid) async {
    try {
      final result = await remoteDataSource.createOrder(order, uid);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
