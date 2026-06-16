import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/utils/image_utils.dart';
import 'package:shopease/core/utils/responsive.dart';
import 'package:shopease/features/home/presentation/bloc/home_bloc.dart';
import 'package:shopease/features/home/presentation/bloc/home_event.dart';
import 'package:shopease/features/home/presentation/bloc/home_state.dart';
import 'package:shopease/features/home/presentation/widgets/category_chips.dart';
import 'package:shopease/features/home/presentation/widgets/daily_quest_card.dart';
import 'package:shopease/features/home/presentation/widgets/hero_banner.dart';
import 'package:shopease/features/home/presentation/widgets/product_card.dart';
import 'package:shopease/features/home/presentation/widgets/streak_ribbon.dart';
import 'package:shopease/features/home/presentation/widgets/xp_progress_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial) {
            context.read<HomeBloc>().add(const LoadHome());
            return const SizedBox.shrink();
          }

          if (state is HomeLoading && state is! HomeLoaded) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: AppColors.white30,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Something went wrong',
                      style: GoogleFonts.syne(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: AppColors.white60,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<HomeBloc>().add(const LoadHome()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final loaded = state as HomeLoaded;
          final user = loaded.userProfile;
          final products = loaded.products;
          final selectedCategory = loaded.selectedCategory;

          final trendingProducts = products.where((p) => p.isTrending).toList();
          final displayProducts =
              trendingProducts.isNotEmpty ? trendingProducts : products;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const RefreshHome());
              await Future.delayed(600.ms);
            },
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  expandedHeight: 80.h,
                  collapsedHeight: 80.h,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 44.h, 16.w, 0.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColors.surface,
                            backgroundImage: avatarImageProvider(user?.avatarUrl),
                            child: user?.avatarUrl == null ||
                                    user!.avatarUrl.isEmpty
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 22.sp,
                                    color: AppColors.white60,
                                  )
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Hello, ${user?.displayName ?? 'Shopper'}!',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Ready to discover?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    color: AppColors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (user != null) StreakRibbon(streak: user.streak),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.accent
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.monetization_on_rounded,
                                  size: 14,
                                  color: AppColors.accent,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${user?.coins ?? 0}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
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

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                    child: user != null
                        ? XpProgressBar(xp: user.xp, level: user.level)
                        : const SizedBox.shrink(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: HeroBanner(
                      items: [
                        BannerItem(
                          imageUrl:
                              'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=800',
                          title: 'Summer Sale',
                          subtitle: 'Up to 60% off on trending items',
                        ),
                        BannerItem(
                          imageUrl:
                              'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
                          title: 'New Arrivals',
                          subtitle: 'Check out the latest drops',
                        ),
                        BannerItem(
                          imageUrl:
                              'https://images.unsplash.com/photo-1607082350899-7e105aa886ae?w=800',
                          title: 'Gaming Week',
                          subtitle: 'Exclusive deals on gaming gear',
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 16.h, 0, 8.h),
                    child: CategoryChips(
                      selectedCategory: selectedCategory,
                      onCategorySelected: (category) {
                        context
                            .read<HomeBloc>()
                            .add(LoadProductsByCategory(category));
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                    child: DailyQuestCard(
                      questTitle: 'Buy 2 items today',
                      xpReward: 200,
                      progress: 0,
                      target: 2,
                      onTap: () {},
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trending Now',
                          style: GoogleFonts.syne(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'See All',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (displayProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 48.sp,
                              color: AppColors.white30,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              selectedCategory != null
                                  ? 'No products in $selectedCategory'
                                  : 'No products yet',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                color: AppColors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount(context),
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductCard(
                            product: displayProducts[index],
                            onTap: () => context.push('/product/${displayProducts[index].id}'),
                          );
                        },
                        childCount: displayProducts.length,
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: SizedBox(height: 32.h),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _crossAxisCount(BuildContext context) => Responsive.gridColumns(context);
}
