import 'package:dartz/dartz.dart' hide Order;
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, Order>> placeOrder(Order order, String uid);
}
