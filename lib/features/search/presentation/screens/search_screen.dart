import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/constants/app_constants.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/utils/responsive.dart';
import 'package:shopease/features/home/presentation/widgets/product_card.dart';
import 'package:shopease/features/search/presentation/bloc/search_bloc.dart';
import 'package:shopease/features/search/presentation/bloc/search_event.dart';
import 'package:shopease/features/search/presentation/bloc/search_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 500);
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<SearchBloc>().add(SearchProducts(
          query: value,
          category: _selectedCategory,
          minPrice: _priceRange.start > 0 ? _priceRange.start : null,
          maxPrice: _priceRange.end < 500 ? _priceRange.end : null,
          minRating: _minRating,
        ));
  }

  void _clearSearch() {
    _searchController.clear();
    _selectedCategory = null;
    _priceRange = const RangeValues(0, 500);
    _minRating = null;
    context.read<SearchBloc>().add(const ClearSearch());
    _focusNode.requestFocus();
  }

  void _showFilterSheet() {
    String? tempCategory = _selectedCategory;
    RangeValues tempPriceRange = _priceRange;
    double? tempMinRating = _minRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: 520.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                border: Border(
                  top: BorderSide(color: AppColors.white10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 12.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.white30,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: GoogleFonts.syne(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempCategory = null;
                              tempPriceRange = const RangeValues(0, 500);
                              tempMinRating = null;
                            });
                          },
                          child: Text(
                            'Reset',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      children: [
                        Text(
                          'Category',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        12.verticalSpace,
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: AppConstants.categories.map((cat) {
                            final selected = tempCategory == cat;
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  tempCategory = selected ? null : cat;
                                });
                              },
                              child: AnimatedScale(
                                scale: selected ? 1.05 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.card,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.white10,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: selected
                                          ? AppColors.white
                                          : AppColors.white60,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        24.verticalSpace,
                        Text(
                          'Price Range',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        8.verticalSpace,
                        Text(
                          '\$${tempPriceRange.start.toStringAsFixed(0)} - \$${tempPriceRange.end.toStringAsFixed(0)}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14.sp,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        RangeSlider(
                          values: tempPriceRange,
                          min: 0,
                          max: 500,
                          divisions: 50,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.white10,
                          labels: RangeLabels(
                            '\$${tempPriceRange.start.toStringAsFixed(0)}',
                            '\$${tempPriceRange.end.toStringAsFixed(0)}',
                          ),
                          onChanged: (values) {
                            setSheetState(() {
                              tempPriceRange = values;
                            });
                          },
                        ),
                        24.verticalSpace,
                        Text(
                          'Minimum Rating',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        12.verticalSpace,
                        Wrap(
                          spacing: 8.w,
                          children: [null, 3.0, 4.0, 5.0].map((rating) {
                            final selected = tempMinRating == rating;
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  tempMinRating =
                                      selected ? null : rating;
                                });
                              },
                              child: AnimatedScale(
                                scale: selected ? 1.05 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.accent
                                        : AppColors.card,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.accent
                                          : AppColors.white10,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (rating != null) ...[
                                        Icon(
                                          Icons.star,
                                          size: 16.sp,
                                          color: selected
                                              ? AppColors.white
                                              : AppColors.accent,
                                        ),
                                        4.horizontalSpace,
                                      ],
                                      Text(
                                        rating == null
                                            ? 'Any'
                                            : '${rating.toInt()}+',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: selected
                                              ? AppColors.white
                                              : AppColors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = tempCategory;
                            _priceRange = tempPriceRange;
                            _minRating = tempMinRating;
                          });
                          Navigator.pop(ctx);
                          final q = _searchController.text;
                          if (q.isNotEmpty) {
                            context.read<SearchBloc>().add(SearchProducts(
                                  query: q,
                                  category: _selectedCategory,
                                  minPrice: _priceRange.start > 0
                                      ? _priceRange.start
                                      : null,
                                  maxPrice: _priceRange.end < 500
                                      ? _priceRange.end
                                      : null,
                                  minRating: _minRating,
                                ));
                          }
                        },
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.white10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white,
                          fontSize: 14.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: AppColors.white30,
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.white30,
                            size: 20.sp,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.white60,
                                    size: 18.sp,
                                  ),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      width: 48.h,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.white10),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: _selectedCategory != null ||
                                _minRating != null ||
                                _priceRange != const RangeValues(0, 500)
                            ? AppColors.primary
                            : AppColors.white60,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedCategory != null ||
                _minRating != null ||
                _priceRange != const RangeValues(0, 500))
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: SizedBox(
                  height: 36.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedCategory != null)
                        _buildFilterChip(
                          label: _selectedCategory!,
                          onRemoved: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                            _onSearchChanged(_searchController.text);
                          },
                        ),
                      if (_priceRange != const RangeValues(0, 500))
                        _buildFilterChip(
                          label:
                              '\$${_priceRange.start.toStringAsFixed(0)}-\$${_priceRange.end.toStringAsFixed(0)}',
                          onRemoved: () {
                            setState(() {
                              _priceRange = const RangeValues(0, 500);
                            });
                            _onSearchChanged(_searchController.text);
                          },
                        ),
                      if (_minRating != null)
                        _buildFilterChip(
                          label: '${_minRating!.toInt()}+ Stars',
                          onRemoved: () {
                            setState(() {
                              _minRating = null;
                            });
                            _onSearchChanged(_searchController.text);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            16.verticalSpace,
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64.sp,
                            color: AppColors.white30,
                          ),
                          16.verticalSpace,
                          Text(
                            'Search for products',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              color: AppColors.white60,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is SearchError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 64,
                            ),
                            16.verticalSpace,
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.white60,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is SearchLoaded) {
                    if (state.results.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64.sp,
                              color: AppColors.white30,
                            ),
                            16.verticalSpace,
                            Text(
                              'No products found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                color: AppColors.white60,
                              ),
                            ),
                            if (state.query.isNotEmpty)
                              Text(
                                'for "${state.query}"',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: AppColors.white30,
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = Responsive.gridColumns(context);
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.results.length} results${state.query.isNotEmpty ? ' for "${state.query}"' : ''}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  color: AppColors.white60,
                                ),
                              ),
                              12.verticalSpace,
                              Expanded(
                                child: GridView.builder(
                                  itemCount: state.results.length,
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: 12.h,
                                    crossAxisSpacing: 12.w,
                                    childAspectRatio: 0.65,
                                  ),
                                  itemBuilder: (context, index) {
                                    final product = state.results[index];
                                    return ProductCard(
                                      product: product,
                                      onTap: () {
                                        context.push(
                                          '/product/${product.id}',
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemoved,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              4.horizontalSpace,
              GestureDetector(
                onTap: onRemoved,
                child: Icon(
                  Icons.close,
                  size: 14.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: 200.ms,
    );
  }
}
