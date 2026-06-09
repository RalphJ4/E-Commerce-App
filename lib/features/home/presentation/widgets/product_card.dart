import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/utils/formatter.dart';
import 'package:shopease/features/home/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'product_${product.id}',
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppColors.white30,
                            ),
                          ),
                        ),
                      ),
                      if (product.discountPercentage > 0)
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '-${product.discountPercentage.toStringAsFixed(0)}%',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.background,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 10.sp,
                                color: AppColors.white,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '+15 XP',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              Formatter.formatPrice(product.price),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (product.originalPrice != null) ...[
                              SizedBox(width: 4.w),
                              Text(
                                Formatter.formatPrice(product.originalPrice!),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10.sp,
                                  decoration:
                                      TextDecoration.lineThrough,
                                  color: AppColors.white30,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 12.sp,
                              color: AppColors.accent,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white60,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${product.reviewCount})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.sp,
                                color: AppColors.white30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}
