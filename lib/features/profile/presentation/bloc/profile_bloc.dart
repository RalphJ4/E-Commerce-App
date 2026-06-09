import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/features/profile/domain/usecases/get_order_history_usecase.dart';
import 'package:shopease/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:shopease/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:shopease/features/profile/presentation/bloc/profile_event.dart';
import 'package:shopease/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateAvatarUseCase updateAvatarUseCase;
  final GetOrderHistoryUseCase getOrderHistoryUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateAvatarUseCase,
    required this.getOrderHistoryUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateAvatar>(_onUpdateAvatar);
    on<LoadOrderHistory>(_onLoadOrderHistory);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getProfileUseCase.call(event.uid);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateAvatar(
    UpdateAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is ProfileLoaded) {
      emit(ProfileAvatarUploading(
        profile: current.profile,
        orders: current.orders,
      ));
      final result = await updateAvatarUseCase.call(event.filePath, current.profile.uid);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (avatarUrl) {
          final updatedProfile = current.profile.copyWith(avatarUrl: avatarUrl);
          emit(ProfileLoaded(profile: updatedProfile, orders: current.orders));
        },
      );
    }
  }

  Future<void> _onLoadOrderHistory(
    LoadOrderHistory event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is ProfileLoaded) {
      final result = await getOrderHistoryUseCase.call(event.uid);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (orders) => emit(ProfileLoaded(profile: current.profile, orders: orders)),
      );
    }
  }
}
