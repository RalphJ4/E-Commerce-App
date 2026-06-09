import 'package:dartz/dartz.dart' hide Order;
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';
import 'package:shopease/features/checkout/domain/repositories/checkout_repository.dart';

class PlaceOrderUseCase {
  final CheckoutRepository repository;

  PlaceOrderUseCase(this.repository);

  Future<Either<Failure, Order>> call(Order order, String uid) async {
    final updatedOrder = order.copyWith(xpAwarded: AppConstants.xpPerOrder);
    return repository.placeOrder(updatedOrder, uid);
  }
}
