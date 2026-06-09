import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class LoadHome extends HomeEvent {
  const LoadHome();
}

final class LoadProductsByCategory extends HomeEvent {
  final String category;

  const LoadProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

final class RefreshHome extends HomeEvent {
  const RefreshHome();
}
