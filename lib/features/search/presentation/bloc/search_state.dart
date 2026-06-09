import 'package:equatable/equatable.dart';
import 'package:shopease/features/home/domain/entities/product.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  final List<Product> results;
  final String query;
  final Map<String, dynamic>? appliedFilters;

  const SearchLoaded({
    required this.results,
    this.query = '',
    this.appliedFilters,
  });

  @override
  List<Object?> get props => [results, query, appliedFilters];
}

final class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
