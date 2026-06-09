import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/utils/formatter.dart';
import 'package:shopease/features/cart/domain/entities/cart_item.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_state.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';
import 'package:shopease/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:shopease/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:shopease/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  final String uid;

  const CheckoutScreen({
    super.key,
    required this.uid,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _confettiController;
  bool _showSuccessOverlay = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          HapticFeedback.heavyImpact();
          _confettiController.play();
          setState(() => _showSuccessOverlay = true);
          Future.delayed(3.seconds, () {
            if (mounted) {
              setState(() => _showSuccessOverlay = false);
              Navigator.of(context).pop(true);
            }
          });
        }
        if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: false,
          appBar: _buildAppBar(state),
          body: Stack(
            children: [
              _buildBody(state),
              if (_showSuccessOverlay && state is CheckoutSuccess)
                _buildSuccessOverlay(state),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(CheckoutState state) {
    return AppBar(
      title: Text('Checkout (${state.currentStep + 1}/3)'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          if (state.currentStep > 0) {
            context.read<CheckoutBloc>().add(ResetCheckout());
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildBody(CheckoutState state) {
    if (state is CheckoutProcessing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Processing your order...',
              style: TextStyle(color: AppColors.white60, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildStepIndicator(state.currentStep),
          SizedBox(height: 24.h),
          if (state.currentStep == 0) _buildShippingForm(),
          if (state.currentStep == 1) _buildPaymentMethod(state),
          if (state.currentStep == 2) _buildOrderSummary(state),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;
        return Expanded(
          child: Row(
            children: [
              if (index > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? AppColors.primary : AppColors.white10,
                  ),
                ),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : AppColors.surface,
                  border: Border.all(
                    color: isCurrent ? AppColors.accent : AppColors.white10,
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.spaceGrotesk(
                      color: isActive ? AppColors.white : AppColors.white30,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShippingForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shipping Address',
                  style: Theme.of(context).textTheme.displaySmall)
              .animate()
              .fadeIn()
              .slideX(),
          SizedBox(height: 20.h),
          _buildTextField(_nameController, 'Full Name', Icons.person),
          SizedBox(height: 12.h),
          _buildTextField(_phoneController, 'Phone Number', Icons.phone),
          SizedBox(height: 12.h),
          _buildTextField(
              _addressController, 'Street Address', Icons.home_outlined),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_cityController, 'City', Icons.location_city),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(_zipController, 'ZIP Code', Icons.pin),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<CheckoutBloc>().add(UpdateShippingAddress(
                        name: _nameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        address: _addressController.text.trim(),
                        city: _cityController.text.trim(),
                        zip: _zipController.text.trim(),
                      ));
                }
              },
              child: const Text('Continue to Payment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.white30),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$label is required' : null,
    );
  }

  Widget _buildPaymentMethod(CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method',
                style: Theme.of(context).textTheme.displaySmall)
            .animate()
            .fadeIn()
            .slideX(),
        SizedBox(height: 20.h),
        _buildPaymentOption('Card', Icons.credit_card,
            'Pay with credit or debit card', state),
        SizedBox(height: 12.h),
        _buildPaymentOption('COD', Icons.money, 'Cash on delivery', state),
      ],
    );
  }

  Widget _buildPaymentOption(
      String method, IconData icon, String subtitle, CheckoutState state) {
    final isSelected = state.paymentMethod == method;
    return GestureDetector(
      onTap: () {
        context.read<CheckoutBloc>().add(UpdatePaymentMethod(method));
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.white60,
                size: 28.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.white60,
                      )),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.white30)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: Theme.of(context).textTheme.displaySmall)
            .animate()
            .fadeIn()
            .slideX(),
        SizedBox(height: 16.h),
        _buildFrostedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shipping To',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: AppColors.white60,
                  )),
              SizedBox(height: 8.h),
              Text(state.shippingAddress,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: AppColors.white,
                  )),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _buildFrostedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Method',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: AppColors.white60,
                  )),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    state.paymentMethod == 'Card'
                        ? Icons.credit_card
                        : Icons.money,
                    color: AppColors.accent,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(state.paymentMethod,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: AppColors.white,
                      )),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _buildFrostedCard(
          child: Column(
            children: [
              ..._getCartItems().map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} x${item.quantity}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        Text(
                          Formatter.formatPrice(item.price * item.quantity),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14.sp,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
              const Divider(color: AppColors.white10),
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: GoogleFonts.syne(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        )),
                    Text(
                      Formatter.formatPrice(_getTotal()),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<CheckoutBloc>().add(PlaceOrder(
                    items: _getCartItems().map((i) => OrderItem(
                      productId: i.productId,
                      productName: i.productName,
                      quantity: i.quantity,
                      price: i.price,
                    )).toList(),
                    total: _getTotal(),
                    uid: widget.uid,
                  ));
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text('Place Order - ${Formatter.formatPrice(_getTotal())}'),
          ),
        ),
      ],
    );
  }

  Widget _buildFrostedCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white10,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.white10),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(CheckoutSuccess state) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Stack(
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.accent,
              Colors.cyan,
              Colors.pink,
              Colors.green,
            ],
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 80)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shake(),
                SizedBox(height: 16.h),
                Text('Order Placed!',
                        style: GoogleFonts.syne(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ))
                    .animate()
                    .fadeIn(delay: 300.ms),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppColors.accent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: AppColors.accent, size: 20),
                      SizedBox(width: 8.w),
                      Text('+${state.xpAwarded} XP',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          )),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<CartItem> _getCartItems() {
    final cartState = context.read<CartBloc?>()?.state;
    if (cartState is CartLoaded) {
      return cartState.items;
    }
    return [];
  }

  double _getTotal() {
    final cartState = context.read<CartBloc?>()?.state;
    if (cartState is CartLoaded) {
      return cartState.total;
    }
    return 0;
  }
}
