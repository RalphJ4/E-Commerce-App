import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/core/theme/app_theme.dart';

class CategoryChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryChips({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = AppConstants.categories;

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: AnimatedContainer(
              duration: 300.ms,
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.white10,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.white10,
                ),
              ),
              child: Text(
                category,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.white60,
                ),
              ),
            ).animate(target: isSelected ? 1 : 0).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 200.ms,
                  curve: Curves.easeOutBack,
                ),
          );
        },
      ),
    );
  }
}
