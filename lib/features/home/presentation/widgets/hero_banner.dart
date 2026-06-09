import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/theme/app_theme.dart';

class BannerItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const BannerItem({
    required this.imageUrl,
    required this.title,
    this.subtitle = '',
    this.onTap,
  });
}

class HeroBanner extends StatefulWidget {
  final List<BannerItem> items;

  const HeroBanner({super.key, required this.items});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && widget.items.length > 1) {
        final nextPage = (_currentPage + 1) % widget.items.length;
        _pageController.animateToPage(
          nextPage,
          duration: 400.ms,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return GestureDetector(
                onTap: item.onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surface,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.white30,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.background.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16.h,
                        left: 16.w,
                        right: 16.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.syne(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            if (item.subtitle.isNotEmpty)
                              Text(
                                item.subtitle,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  color: AppColors.white60,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms);
            },
          ),
          if (widget.items.length > 1)
            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.items.length,
                  (index) => AnimatedContainer(
                    duration: 300.ms,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: _currentPage == index ? 20.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.white30,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
