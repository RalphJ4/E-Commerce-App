import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';
import 'package:shopease/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:shopease/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:shopease/features/checkout/presentation/bloc/checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PlaceOrderUseCase placeOrderUseCase;

  CheckoutBloc({
    required this.placeOrderUseCase,
  }) : super(const CheckoutInitial()) {
    on<UpdateShippingAddress>(_onUpdateShippingAddress);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<PlaceOrder>(_onPlaceOrder);
    on<ResetCheckout>(_onResetCheckout);
  }

  void _onUpdateShippingAddress(
    UpdateShippingAddress event,
    Emitter<CheckoutState> emit,
  ) {
    final address =
        '${event.name}\n${event.phone}\n${event.address}\n${event.city}, ${event.zip}';
    emit(CheckoutInitial(
      currentStep: 1,
      shippingAddress: address,
      paymentMethod: state.paymentMethod,
    ));
  }

  void _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<CheckoutState> emit,
  ) {
    emit(CheckoutInitial(
      currentStep: 2,
      shippingAddress: state.shippingAddress,
      paymentMethod: event.paymentMethod,
    ));
  }

  Future<void> _onPlaceOrder(
    PlaceOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutProcessing(
      currentStep: state.currentStep,
      shippingAddress: state.shippingAddress,
      paymentMethod: state.paymentMethod,
    ));

    final order = Order(
      id: '',
      uid: event.uid,
      items: event.items,
      shippingAddress: state.shippingAddress,
      paymentMethod: state.paymentMethod,
      total: event.total,
      createdAt: DateTime.now(),
    );

    final result = await placeOrderUseCase.call(order, event.uid);

    result.fold(
      (failure) => emit(CheckoutError(
        message: failure.message,
        currentStep: state.currentStep,
        shippingAddress: state.shippingAddress,
        paymentMethod: state.paymentMethod,
      )),
      (placedOrder) => emit(CheckoutSuccess(
        order: placedOrder,
        xpAwarded: placedOrder.xpAwarded,
      )),
    );
  }

  void _onResetCheckout(ResetCheckout event, Emitter<CheckoutState> emit) {
    emit(const CheckoutInitial());
  }
}
