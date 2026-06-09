import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/features/search/domain/usecases/search_products_usecase.dart';
import 'package:shopease/features/search/presentation/bloc/search_event.dart';
import 'package:shopease/features/search/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchProductsUseCase searchProductsUseCase;
  Timer? _debounce;

  SearchBloc({
    required this.searchProductsUseCase,
  }) : super(const SearchInitial()) {
    on<SearchProducts>(_onSearchProducts);
    on<UpdateFilters>(_onUpdateFilters);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    final result = await searchProductsUseCase.call(
      query: event.query,
      category: event.category,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      minRating: event.minRating,
    );
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (products) => emit(SearchLoaded(
        results: products,
        query: event.query,
        appliedFilters: {
          if (event.category != null) 'category': event.category,
          if (event.minPrice != null) 'minPrice': event.minPrice,
          if (event.maxPrice != null) 'maxPrice': event.maxPrice,
          if (event.minRating != null) 'minRating': event.minRating,
        },
      )),
    );
  }

  void _onUpdateFilters(
    UpdateFilters event,
    Emitter<SearchState> emit,
  ) {
    if (state is SearchLoaded) {
      final current = state as SearchLoaded;
      add(SearchProducts(
        query: current.query,
        category: event.category ?? current.appliedFilters?['category'],
        minPrice: event.minPrice ?? current.appliedFilters?['minPrice'],
        maxPrice: event.maxPrice ?? current.appliedFilters?['maxPrice'],
        minRating: event.minRating ?? current.appliedFilters?['minRating'],
      ));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    _debounce?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
