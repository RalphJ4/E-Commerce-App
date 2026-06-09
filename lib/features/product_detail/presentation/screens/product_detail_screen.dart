import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/utils/formatter.dart';
import 'package:shopease/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:shopease/features/product_detail/presentation/bloc/product_detail_event.dart';
import 'package:shopease/features/product_detail/presentation/bloc/product_detail_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedColor = 0;
  int _selectedSize = 0;
  int _quantity = 1;

  final _sellers = [
    'TechVault Inc.',
    'UrbanStyle Co.',
    'PixelMart',
    'NovaGoods',
    'EliteCrate',
  ];

  final _colors = ['#7C3AED', '#F59E0B', '#10B981', '#EF4444', '#3B82F6'];
  final _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  String get _randomSeller => _sellers[Random().nextInt(_sellers.length)];

  @override
  void initState() {
    super.initState();
    context
        .read<ProductDetailBloc>()
        .add(LoadProductDetail(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ProductDetailError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 64),
                    16.verticalSpace,
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            color: AppColors.white60, fontSize: 14.sp)),
                    24.verticalSpace,
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<ProductDetailBloc>()
                          .add(LoadProductDetail(widget.productId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProductDetailLoaded) {
            final product = state.product;
            final seller = _randomSeller;

            final scrollView = CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 320.h,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.broken_image,
                                color: AppColors.white30, size: 64),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.background.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.verticalSpace,
                        Text(product.name,
                            style: GoogleFonts.syne(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            )),
                        8.verticalSpace,
                        Row(
                          children: [
                            Icon(Icons.store, size: 16.sp,
                                color: AppColors.primary),
                            6.horizontalSpace,
                            Text(seller,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  color: AppColors.white60,
                                )),
                          ],
                        ),
                        16.verticalSpace,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatter.formatPrice(product.price),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            12.horizontalSpace,
                            if (product.originalPrice != null &&
                                product.originalPrice! > product.price)
                              Text(
                                Formatter.formatPrice(product.originalPrice!),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16.sp,
                                  color: AppColors.white30,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            12.horizontalSpace,
                            if (product.discountPercentage > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '-${product.discountPercentage.toStringAsFixed(0)}%',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        12.verticalSpace,
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < product.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColors.accent,
                                size: 18.sp,
                              ),
                            ),
                            8.horizontalSpace,
                            Text(
                              '(${product.reviewCount} reviews)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                color: AppColors.white60,
                              ),
                            ),
                          ],
                        ),
                        16.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent.withValues(alpha: 0.15),
                                AppColors.primary.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome,
                                  color: AppColors.accent, size: 18.sp),
                              8.horizontalSpace,
                              Text(
                                '+50 XP on purchase',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        24.verticalSpace,
                        Text('Color',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            )),
                        12.verticalSpace,
                        Row(
                          children: List.generate(
                            _colors.length,
                            (i) => GestureDetector(
                              onTap: () => setState(() => _selectedColor = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: EdgeInsets.only(right: 12.w),
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                          _colors[i].replaceFirst('#', '0xFF'))),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor == i
                                        ? AppColors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: _selectedColor == i
                                      ? [
                                          BoxShadow(
                                            color: Color(int.parse(_colors[i]
                                                    .replaceFirst('#', '0xFF')))
                                                .withValues(alpha: 0.5),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: _selectedColor == i
                                    ? const Icon(Icons.check,
                                        color: AppColors.white, size: 18)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        20.verticalSpace,
                        Text('Size',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            )),
                        12.verticalSpace,
                        Row(
                          children: List.generate(
                            _sizes.length,
                            (i) => GestureDetector(
                              onTap: () => setState(() => _selectedSize = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: EdgeInsets.only(right: 12.w),
                                width: 48.w,
                                height: 40.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedSize == i
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedSize == i
                                        ? AppColors.primary
                                        : AppColors.white10,
                                  ),
                                ),
                                child: Text(
                                  _sizes[i],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedSize == i
                                        ? AppColors.white
                                        : AppColors.white60,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        20.verticalSpace,
                        Text('Description',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            )),
                        8.verticalSpace,
                        Text(
                          product.description,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            color: AppColors.white60,
                            height: 1.6,
                          ),
                        ),
                        100.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ],
            );

            return Stack(
              children: [
                scrollView.animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.95),
                      border: Border(
                        top: BorderSide(color: AppColors.white10),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.white10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                  child: const Icon(Icons.remove,
                                      color: AppColors.white60, size: 18),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Text(
                                    '$_quantity',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_quantity < 99) {
                                      setState(() => _quantity++);
                                    }
                                  },
                                  child: const Icon(Icons.add,
                                      color: AppColors.white60, size: 18),
                                ),
                              ],
                            ),
                          ),
                          16.horizontalSpace,
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.read<ProductDetailBloc>().add(
                                      AddToCart(
                                        productId: product.id,
                                        quantity: _quantity,
                                        variant:
                                            '${_colors[_selectedColor]}_${_sizes[_selectedSize]}',
                                      ),
                                    );
                              },
                              child: Container(
                                height: 52.h,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFF6D28D9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_cart,
                                        color: AppColors.white, size: 20),
                                    8.horizontalSpace,
                                    Text(
                                      'Add to Cart',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
