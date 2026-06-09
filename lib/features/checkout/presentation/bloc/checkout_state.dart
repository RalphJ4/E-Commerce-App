import 'package:equatable/equatable.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';

sealed class CheckoutState extends Equatable {
  final int currentStep;
  final String shippingAddress;
  final String paymentMethod;

  const CheckoutState({
    this.currentStep = 0,
    this.shippingAddress = '',
    this.paymentMethod = '',
  });

  @override
  List<Object?> get props => [currentStep, shippingAddress, paymentMethod];
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial({
    super.currentStep,
    super.shippingAddress,
    super.paymentMethod,
  });
}

final class CheckoutProcessing extends CheckoutState {
  const CheckoutProcessing({
    super.currentStep,
    super.shippingAddress,
    super.paymentMethod,
  });
}

final class CheckoutSuccess extends CheckoutState {
  final Order order;
  final int xpAwarded;

  const CheckoutSuccess({
    required this.order,
    required this.xpAwarded,
    super.currentStep,
    super.shippingAddress,
    super.paymentMethod,
  });

  @override
  List<Object?> get props => [order, xpAwarded, ...super.props];
}

final class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError({
    required this.message,
    super.currentStep,
    super.shippingAddress,
    super.paymentMethod,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}
