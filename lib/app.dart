import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/di/service_locator.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_event.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_state.dart';
import 'package:shopease/features/auth/presentation/screens/auth_screen.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shopease/features/cart/presentation/screens/cart_screen.dart';
import 'package:shopease/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:shopease/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:shopease/features/home/presentation/bloc/home_bloc.dart';
import 'package:shopease/features/home/presentation/bloc/home_event.dart';
import 'package:shopease/features/home/presentation/screens/home_screen.dart';
import 'package:shopease/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:shopease/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:shopease/features/product_detail/presentation/screens/product_detail_screen.dart';
import 'package:shopease/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:shopease/features/profile/presentation/screens/profile_screen.dart';
import 'package:shopease/features/search/presentation/bloc/search_bloc.dart';
import 'package:shopease/features/search/presentation/screens/search_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _authRefreshNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authRefreshNotifier.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    _authRefreshNotifier.value++;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<AuthBloc>()..add(const CheckAuthStatus())),
            BlocProvider(create: (_) => sl<HomeBloc>()..add(const LoadHome())),
            BlocProvider(create: (_) => sl<CartBloc>()),
            BlocProvider(create: (_) => sl<ProfileBloc>()),
          ],
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              _onAuthChanged();
            },
            child: Builder(
              builder: (context) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'ShopEase',
                  theme: AppTheme.darkTheme,
                  routerConfig: _buildRouter(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: _authRefreshNotifier,
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isLoggedIn = authState is Authenticated;
        final isAuthRoute = state.matchedLocation == '/auth';

        if (!isLoggedIn && !isAuthRoute) {
          return '/auth';
        }

        if (isLoggedIn && isAuthRoute) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return _MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<SearchBloc>(),
                    child: const SearchScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/cart',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<CartBloc>(),
                    child: const CartScreen(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => ProfileScreen(
                    uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/product/:id',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => sl<ProductDetailBloc>(),
              child: ProductDetailScreen(productId: id),
            );
          },
        ),
        GoRoute(
          path: '/checkout',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
            return BlocProvider(
              create: (_) => sl<CheckoutBloc>(),
              child: CheckoutScreen(
                uid: uid,
              ),
            );
          },
        ),
        GoRoute(
          path: '/leaderboard',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => LeaderboardScreen(
            currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ),
      ],
    );
  }
}

class _MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShell({required this.navigationShell});

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _xp = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _listenToUserData();
  }

  void _listenToUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      setState(() {
        _xp = data['xp'] as int? ?? 0;
        _level = data['level'] as int? ?? 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return Row(
            children: [
              _SideNav(
                currentIndex: widget.navigationShell.currentIndex,
                xp: _xp,
                level: _level,
                onTap: widget.navigationShell.goBranch,
              ),
              Expanded(child: widget.navigationShell),
            ],
          );
        }
        return Scaffold(
          body: widget.navigationShell,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.white10),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          label: 'Home',
                          isSelected: widget.navigationShell.currentIndex == 0,
                          onTap: () => widget.navigationShell.goBranch(0),
                        ),
                        _NavItem(
                          icon: Icons.search_outlined,
                          activeIcon: Icons.search,
                          label: 'Search',
                          isSelected: widget.navigationShell.currentIndex == 1,
                          onTap: () => widget.navigationShell.goBranch(1),
                        ),
                        _NavItem(
                          icon: Icons.shopping_cart_outlined,
                          activeIcon: Icons.shopping_cart,
                          label: 'Cart',
                          isSelected: widget.navigationShell.currentIndex == 2,
                          onTap: () => widget.navigationShell.goBranch(2),
                        ),
                        _NavItem(
                          icon: Icons.person_outline,
                          activeIcon: Icons.person,
                          label: 'Profile',
                          isSelected: widget.navigationShell.currentIndex == 3,
                          onTap: () => widget.navigationShell.goBranch(3),
                        ),
                      ],
                    ),
                    if (_xp > 0)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 10.sp,
                              color: AppColors.accent,
                            ),
                            4.horizontalSpace,
                            Text(
                              'Lv.$_level',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9.sp,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            6.horizontalSpace,
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.r),
                                child: LinearProgressIndicator(
                                  value: (_xp % 500) / 500,
                                  backgroundColor: AppColors.white10,
                                  valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                  minHeight: 3.h,
                                ),
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
        );
      },
    );
  }
}

class _SideNav extends StatelessWidget {
  final int currentIndex;
  final int xp;
  final int level;
  final void Function(int) onTap;

  const _SideNav({
    required this.currentIndex,
    required this.xp,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(height: 48),
          Text(
            'ShopEase',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          if (xp > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 12, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text(
                    'Lv.$level',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (xp % 500) / 500,
                        backgroundColor: AppColors.white10,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 24),
          _SideNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _SideNavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _SideNavItem(
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart,
            label: 'Cart',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _SideNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.primary : AppColors.white30,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isSelected ? AppColors.primary : AppColors.white30,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.white30,
              size: 22.sp,
            ),
            2.verticalSpace,
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.sp,
                color: isSelected ? AppColors.primary : AppColors.white30,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      duration: 200.ms,
    );
  }
}
