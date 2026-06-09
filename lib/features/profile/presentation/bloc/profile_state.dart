import 'package:equatable/equatable.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/features/checkout/domain/entities/order.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final User profile;
  final List<Order> orders;

  const ProfileLoaded({
    required this.profile,
    this.orders = const [],
  });

  @override
  List<Object?> get props => [profile, orders];
}

final class ProfileAvatarUploading extends ProfileState {
  final User profile;
  final List<Order> orders;

  const ProfileAvatarUploading({
    required this.profile,
    this.orders = const [],
  });

  @override
  List<Object?> get props => [profile, orders];
}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
