import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/core/utils/formatter.dart';
import 'package:shopease/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:shopease/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:shopease/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:shopease/features/leaderboard/presentation/bloc/leaderboard_state.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatefulWidget {
  final String currentUserId;

  const LeaderboardScreen({super.key, this.currentUserId = ''});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<LeaderboardBloc>()
        .add(LoadLeaderboard(currentUserId: widget.currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading || state is LeaderboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LeaderboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  SizedBox(height: 16.h),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.white60)),
                  SizedBox(height: 16.h),
                  TextButton.icon(
                    onPressed: () {
                      context.read<LeaderboardBloc>().add(
                            LoadLeaderboard(
                                currentUserId: widget.currentUserId),
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is LeaderboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeaderboardBloc>().add(
                      LoadLeaderboard(
                          currentUserId: widget.currentUserId),
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    _buildPodium(state.entries),
                    SizedBox(height: 24.h),
                    _buildRankList(state.entries),
                    if (state.currentUserEntry != null &&
                        state.currentUserEntry!.rank > 10)
                      Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: _buildCurrentUserCard(state.currentUserEntry!),
                      ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.emoji_events, color: AppColors.accent, size: 48.sp),
        SizedBox(height: 8.h),
        Text('Top Spenders',
            style: GoogleFonts.syne(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            )),
        Text('Compete for the top spot!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: AppColors.white30,
            )),
      ],
    ).animate().fadeIn().slideY();
  }

  Widget _buildPodium(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final top3 = entries.length >= 3 ? entries.sublist(0, 3) : entries;

    return SizedBox(
      height: 260.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length >= 2) ...[
            Expanded(child: _buildPodiumCard(top3[1], 2, 200.h)),
            SizedBox(width: 8.w),
          ],
          if (top3.isNotEmpty)
            Expanded(child: _buildPodiumCard(top3[0], 1, 260.h)),
          if (top3.length >= 3) ...[
            SizedBox(width: 8.w),
            Expanded(child: _buildPodiumCard(top3[2], 3, 170.h)),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPodiumCard(LeaderboardEntry entry, int rank, double height) {
    final crownIcons = {1: '👑', 2: '🥈', 3: '🥉'};
    final podiumColors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty)
          CircleAvatar(
            radius: rank == 1 ? 28.w : 22.w,
            backgroundColor: podiumColors[rank]!.withValues(alpha: 0.3),
            backgroundImage: CachedNetworkImageProvider(entry.avatarUrl!),
          )
        else
          CircleAvatar(
            radius: rank == 1 ? 28.w : 22.w,
            backgroundColor: podiumColors[rank]!.withValues(alpha: 0.3),
            child: Text(
              entry.displayName.isNotEmpty
                  ? entry.displayName[0].toUpperCase()
                  : '?',
              style: GoogleFonts.syne(
                fontSize: rank == 1 ? 20.sp : 16.sp,
                fontWeight: FontWeight.bold,
                color: podiumColors[rank],
              ),
            ),
          ),
        SizedBox(height: 4.h),
        Text(crownIcons[rank]!, style: TextStyle(fontSize: 24.sp)),
        SizedBox(height: 4.h),
        Text(
          entry.displayName.length > 10
              ? '${entry.displayName.substring(0, 10)}...'
              : entry.displayName,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
                      Text(
                        '\$${entry.totalSpent.toStringAsFixed(0)}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                      ),
                    ),
        SizedBox(height: 8.h),
        Container(
          width: 56.w,
          height: height * 0.4,
          decoration: BoxDecoration(
            color: podiumColors[rank]!.withValues(alpha: 0.3),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12.r),
            ),
            border: Border.all(
              color: podiumColors[rank]!.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.syne(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: podiumColors[rank],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankList(List<LeaderboardEntry> entries) {
    final listEntries = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

    if (listEntries.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        ...listEntries.map((entry) => _buildRankItem(entry, false)),
      ],
    );
  }

  Widget _buildRankItem(LeaderboardEntry entry, bool isCurrentUser) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.white10,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isCurrentUser ? AppColors.primary : AppColors.white10,
              width: isCurrentUser ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36.w,
                child: Text(
                  '#${entry.rank}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: entry.rank <= 3 ? AppColors.accent : AppColors.white60,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              CircleAvatar(
                radius: 18.w,
                backgroundColor: AppColors.surface,
                backgroundImage: entry.avatarUrl != null &&
                        entry.avatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(entry.avatarUrl!)
                    : null,
                child: entry.avatarUrl == null || entry.avatarUrl!.isEmpty
                    ? Text(
                        entry.displayName.isNotEmpty
                            ? entry.displayName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.syne(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Level ${entry.level}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: AppColors.white30,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatter.formatPrice(entry.totalSpent),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildCurrentUserCard(LeaderboardEntry entry) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.white10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text('Your Rank',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: AppColors.white30,
                  )),
            ),
            const Expanded(child: Divider(color: AppColors.white10)),
          ],
        ),
        SizedBox(height: 8.h),
        _buildRankItem(entry, true),
      ],
    );
  }
}
