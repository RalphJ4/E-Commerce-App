import 'package:dartz/dartz.dart' hide Order;
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';
import 'package:shopease/features/profile/domain/repositories/profile_repository.dart';

class GetOrderHistoryUseCase {
  final ProfileRepository repository;

  GetOrderHistoryUseCase(this.repository);

  Future<Either<Failure, List<Order>>> call(String uid) {
    return repository.getOrderHistory(uid);
  }
}
