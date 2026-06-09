import 'package:equatable/equatable.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

final class UpdateShippingAddress extends CheckoutEvent {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String zip;

  const UpdateShippingAddress({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.zip,
  });

  @override
  List<Object?> get props => [name, phone, address, city, zip];
}

final class UpdatePaymentMethod extends CheckoutEvent {
  final String paymentMethod;

  const UpdatePaymentMethod(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

final class PlaceOrder extends CheckoutEvent {
  final List<OrderItem> items;
  final double total;
  final String uid;

  const PlaceOrder({
    required this.items,
    required this.total,
    required this.uid,
  });

  @override
  List<Object?> get props => [items, total, uid];
}

final class ResetCheckout extends CheckoutEvent {
  const ResetCheckout();
}
