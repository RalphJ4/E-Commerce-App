import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/theme/app_theme.dart';

class DailyQuestCard extends StatelessWidget {
  final String questTitle;
  final int xpReward;
  final int progress;
  final int target;
  final VoidCallback? onTap;

  const DailyQuestCard({
    super.key,
    required this.questTitle,
    required this.xpReward,
    this.progress = 0,
    this.target = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (progress / target).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.accent.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Daily Quest',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        questTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: AnimatedContainer(
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                          height: 4.h,
                          width: double.infinity,
                          color: AppColors.white10,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    Color(0xFFFF6B35),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$progress / $target',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10.sp,
                          color: AppColors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+$xpReward',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                      Text(
                        'XP',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}
