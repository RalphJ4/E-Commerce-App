import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/services/storage_services.dart';

class XpProgressBar extends StatelessWidget {
  final int xp;
  final int level;

  const XpProgressBar({
    super.key,
    required this.xp,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final progress = StorageService.xpProgressInLevel(xp);
    final xpToNext = StorageService.xpForNextLevel(xp);
    final title = StorageService.levelTitle(level);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.white10,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.r,
                  vertical: 6.r,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF9D4EFF)],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Lv. $level $title',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: AnimatedContainer(
                        duration: 800.ms,
                        curve: Curves.easeOutCubic,
                        height: 6.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white10,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.accent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${xp % 500}/$xpToNext XP',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.sp,
                        color: AppColors.white60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1);
  }
}
