import 'package:equatable/equatable.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/home/domain/entities/user_profile.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  final List<Product> products;
  final UserProfile? userProfile;
  final String? selectedCategory;

  const HomeLoaded({
    required this.products,
    this.userProfile,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [products, userProfile, selectedCategory];
}

final class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
