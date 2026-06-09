import 'package:equatable/equatable.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchProducts extends SearchEvent {
  final String query;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  const SearchProducts({
    required this.query,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
  });

  @override
  List<Object?> get props => [query, category, minPrice, maxPrice, minRating];
}

final class UpdateFilters extends SearchEvent {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  const UpdateFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
  });

  @override
  List<Object?> get props => [category, minPrice, maxPrice, minRating];
}

final class ClearSearch extends SearchEvent {
  const ClearSearch();
}
