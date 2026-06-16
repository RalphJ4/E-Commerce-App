import 'dart:typed_data';
import 'package:dartz/dartz.dart' hide Order;
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> getProfile(String uid);
  Future<Either<Failure, String>> updateAvatar(String uid, Uint8List imageBytes);
  Future<Either<Failure, List<Order>>> getOrderHistory(String uid);
}
