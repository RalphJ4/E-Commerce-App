import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/utils/formatter.dart';
import 'package:shopease/core/services/storage_services.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';
import 'package:shopease/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:shopease/features/profile/presentation/bloc/profile_event.dart';
import 'package:shopease/features/profile/presentation/bloc/profile_state.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  static const List<Map<String, String>> _allBadges = [
    {'id': 'Welcome', 'icon': '🎉', 'label': 'Welcome'},
    {'id': 'First Purchase', 'icon': '🛍️', 'label': 'First Purchase'},
    {'id': 'Big Spender', 'icon': '💎', 'label': 'Big Spender'},
    {'id': 'Speed Shopper', 'icon': '⚡', 'label': 'Speed Shopper'},
    {'id': 'Streak Master', 'icon': '🔥', 'label': 'Streak Master'},
    {'id': 'Level 5', 'icon': '⭐', 'label': 'Level 5'},
    {'id': 'Level 10', 'icon': '🌟', 'label': 'Level 10'},
    {'id': 'Level 20', 'icon': '💫', 'label': 'Level 20'},
    {'id': '10 Orders', 'icon': '📦', 'label': '10 Orders'},
    {'id': '50 Orders', 'icon': '📦', 'label': '50 Orders'},
    {'id': 'Reviewer', 'icon': '✍️', 'label': 'Reviewer'},
    {'id': 'Social Butterfly', 'icon': '🦋', 'label': 'Social Butterfly'},
    {'id': 'Explorer', 'icon': '🧭', 'label': 'Explorer'},
    {'id': 'Collector', 'icon': '🏆', 'label': 'Collector'},
    {'id': 'Veteran', 'icon': '🎖️', 'label': 'Veteran'},
    {'id': 'Elite', 'icon': '👑', 'label': 'Elite'},
    {'id': 'Legend', 'icon': '🏅', 'label': 'Legend'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile(widget.uid));
    context.read<ProfileBloc>().add(LoadOrderHistory(widget.uid));
  }

  Future<void> _pickImage() async {
    HapticFeedback.mediumImpact();
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (file != null) {
      context.read<ProfileBloc>().add(UpdateAvatar(file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError && state is! ProfileLoaded) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  SizedBox(height: 16.h),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.white60)),
                ],
              ),
            );
          }
          if (state is ProfileLoaded || state is ProfileAvatarUploading) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileAvatarUploading).profile;
            final orders = state is ProfileLoaded
                ? state.orders
                : (state as ProfileAvatarUploading).orders;
            final isUploading = state is ProfileAvatarUploading;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(LoadProfile(widget.uid));
                context.read<ProfileBloc>().add(LoadOrderHistory(widget.uid));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildAvatarSection(profile, isUploading),
                    SizedBox(height: 20.h),
                    _buildStatsRow(profile),
                    SizedBox(height: 20.h),
                    _buildAchievementsGrid(profile.badges),
                    SizedBox(height: 20.h),
                    _buildOrderHistory(orders),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAvatarSection(User profile, bool isUploading) {
    final level = profile.level;
    final progress = StorageService.xpProgressInLevel(profile.xp);
    return Column(
      children: [
        GestureDetector(
          onTap: isUploading ? null : _pickImage,
          child: Stack(
            children: [
              SizedBox(
                width: 120.w,
                height: 120.w,
                child: CustomPaint(
                  painter: _LevelRingPainter(
                    progress: progress,
                    level: level,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: CircleAvatar(
                      radius: 54.w,
                      backgroundColor: AppColors.surface,
                      backgroundImage: profile.avatarUrl != null &&
                              profile.avatarUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null ||
                              profile.avatarUrl!.isEmpty
                          ? Text(
                              profile.displayName.isNotEmpty
                                  ? profile.displayName[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.syne(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black45,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Icon(Icons.camera_alt,
                      color: AppColors.white, size: 16.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text(profile.displayName,
                style: GoogleFonts.syne(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ))
            .animate()
            .fadeIn(),
        Text('Level $level - ${StorageService.levelTitle(level)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: AppColors.primary,
            )),
        SizedBox(height: 12.h),
        _buildXpBar(profile.xp, progress),
      ],
    );
  }

  Widget _buildXpBar(int xp, double progress) {
    final xpForNext = StorageService.xpForNextLevel(xp);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.white10,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accent,
                          ],
                        ),
                      ),
                      width: (progress * MediaQuery.of(context).size.width -
                              32.w)
                          .clamp(0, double.infinity),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$xp XP • $xpForNext to next level',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12.sp,
              color: AppColors.white30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(User profile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white10,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.monetization_on, '${profile.coins}', 'Coins'),
              _buildDivider(),
              _buildStatItem(
                  Icons.local_fire_department, '${profile.streak}', 'Streak'),
              _buildDivider(),
              _buildStatItem(
                  Icons.shopping_bag, '${profile.totalOrders}', 'Orders'),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 24.sp),
        SizedBox(height: 4.h),
        Text(value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            )),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: AppColors.white30,
            )),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: AppColors.white10,
    );
  }

  Widget _buildAchievementsGrid(List<String> userBadges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievements',
                style: GoogleFonts.syne(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ))
            .animate()
            .fadeIn(),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white10,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.white10),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: _allBadges.length,
                itemBuilder: (context, index) {
                  final badge = _allBadges[index];
                  final unlocked = userBadges.contains(badge['id']);
                  return _buildBadgeItem(badge, unlocked, index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(Map<String, String> badge, bool unlocked, int index) {
    return AnimatedContainer(
      duration: 300.ms,
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: unlocked ? AppColors.primary : AppColors.white10,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge['icon']!,
            style: TextStyle(
              fontSize: 20.sp,
              color: unlocked ? null : AppColors.white10,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            badge['label']!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.sp,
              color: unlocked ? AppColors.white : AppColors.white30,
              fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms);
  }

  Widget _buildOrderHistory(List<Order> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order History',
                    style: GoogleFonts.syne(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ))
                .animate()
                .fadeIn(),
            Text('${orders.length} total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: AppColors.white30,
                )),
          ],
        ),
        SizedBox(height: 12.h),
        if (orders.isEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: AppColors.white10,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.white10),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long,
                        color: AppColors.white30, size: 48.sp),
                    SizedBox(height: 8.h),
                    Text('No orders yet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: AppColors.white30,
                        )),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order).animate().fadeIn(
                  delay: (index * 80).ms, duration: 400.ms);
            },
          ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = order.status == 'delivered'
        ? AppColors.success
        : order.status == 'shipped'
            ? AppColors.accent
            : AppColors.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.white10,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.receipt, color: statusColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${order.items.length} item${order.items.length != 1 ? 's' : ''} • ${Formatter.formatDate(order.createdAt)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: AppColors.white30,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatter.formatPrice(order.total),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelRingPainter extends CustomPainter {
  final double progress;
  final int level;

  _LevelRingPainter({required this.progress, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = AppColors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.primary, AppColors.accent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LevelRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
