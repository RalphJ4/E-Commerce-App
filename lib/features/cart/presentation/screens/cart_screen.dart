import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/utils/formatter.dart';
import 'package:shopease/features/cart/domain/entities/cart_item.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_event.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const LoadCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cart',
            style: GoogleFonts.syne(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            )),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CartError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        color: AppColors.white30, size: 64),
                    16.verticalSpace,
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            color: AppColors.white60, fontSize: 14.sp)),
                    24.verticalSpace,
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<CartBloc>().add(const LoadCart()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          color: AppColors.white30, size: 80.sp),
                      16.verticalSpace,
                      Text('Your cart is empty',
                          style: GoogleFonts.syne(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          )),
                      8.verticalSpace,
                      Text(
                        'Browse products and add items\nto get started',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: AppColors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
            }

            return Column(
              children: [
                if (state.hasActiveStreak)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 12.h),
                    margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        12.horizontalSpace,
                        Expanded(
                          child: Text(
                            'Streak bonus active! 10% off your order',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      state.hasActiveStreak ? 12.h : 16.h,
                      16.w,
                      220.h,
                    ),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _CartItemTile(item: item)
                          .animate()
                          .fadeIn(
                              duration: 300.ms, delay: (index * 80).ms)
                          .slideX(begin: 0.1);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomSheet: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded || state.items.isEmpty) {
            return const SizedBox.shrink();
          }
          return _CartBottomSheet(state: state);
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline,
            color: AppColors.white, size: 28),
      ),
      onDismissed: (_) {
        final bloc = context.read<CartBloc>();
        bloc.add(RemoveItem(itemId: item.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.productName} removed',
                style: GoogleFonts.plusJakartaSans()),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.accent,
              onPressed: () {
                bloc.add(UpdateQuantity(
                  itemId: item.id,
                  quantity: item.quantity,
                ));
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.productImage,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.broken_image,
                      color: AppColors.white30),
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      )),
                  4.verticalSpace,
                  if (item.variant.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.variant,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              color: AppColors.white60)),
                    ),
                  6.verticalSpace,
                  Text(
                    Formatter.formatPrice(item.price),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 100.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (item.quantity > 1) {
                        context.read<CartBloc>().add(UpdateQuantity(
                              itemId: item.id,
                              quantity: item.quantity - 1,
                            ));
                      }
                    },
                    child: Container(
                      width: 32.w,
                      alignment: Alignment.center,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: item.quantity > 1 ? 1.0 : 0.5),
                        duration: 200.ms,
                        builder: (_, value, __) => Opacity(
                          opacity: value,
                          child: const Icon(Icons.remove,
                              color: AppColors.white60, size: 16),
                        ),
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: item.quantity, end: item.quantity),
                    duration: 200.ms,
                    builder: (_, value, __) => Text(
                      '$value',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (item.quantity < 99) {
                        context.read<CartBloc>().add(UpdateQuantity(
                              itemId: item.id,
                              quantity: item.quantity + 1,
                            ));
                      }
                    },
                    child: Container(
                      width: 32.w,
                      alignment: Alignment.center,
                      child: const Icon(Icons.add,
                          color: AppColors.white60, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBottomSheet extends StatelessWidget {
  final CartLoaded state;

  const _CartBottomSheet({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: AppColors.white10),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.discount > 0)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: AppColors.white60,
                        )),
                    Text(Formatter.formatPrice(state.subtotal),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          color: AppColors.white60,
                        )),
                  ],
                ),
              ),
            if (state.discount > 0)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Discount',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: AppColors.accent,
                            )),
                        4.horizontalSpace,
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Text('-${Formatter.formatPrice(state.discount)}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        )),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: GoogleFonts.syne(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    )),
                Text(Formatter.formatPrice(state.total),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    )),
              ],
            ),
            16.verticalSpace,
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Checkout \u2022 ${Formatter.formatPrice(state.total)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
