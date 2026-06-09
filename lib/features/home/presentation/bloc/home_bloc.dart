import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/features/home/domain/entities/product.dart';
import 'package:shopease/features/home/domain/entities/user_profile.dart';
import 'package:shopease/features/home/domain/usecases/get_products_usecase.dart';
import 'package:shopease/features/home/domain/usecases/get_user_profile_usecase.dart';
import 'package:shopease/features/home/presentation/bloc/home_event.dart';
import 'package:shopease/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetProductsUseCase getProductsUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;

  HomeBloc({
    required this.getProductsUseCase,
    required this.getUserProfileUseCase,
  }) : super(const HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<RefreshHome>(_onRefreshHome);
  }

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    final products = await getProductsUseCase.call();
    final productList = products.fold<List<Product>>(
      (_) => [],
      (list) => list,
    );

    UserProfile? user;
    if (_uid.isNotEmpty) {
      final userProfile = await getUserProfileUseCase.call(_uid);
      userProfile.fold((_) {}, (profile) => user = profile);
    }

    emit(HomeLoaded(
      products: productList,
      userProfile: user,
    ));
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;

      emit(HomeLoaded(
        products: current.products,
        userProfile: current.userProfile,
        selectedCategory: event.category,
      ));

      final result =
          await getProductsUseCase.call(category: event.category);

      final products = result.fold<List<Product>>(
        (_) => current.products,
        (list) => list,
      );

      emit(HomeLoaded(
        products: products,
        userProfile: current.userProfile,
        selectedCategory: event.category,
      ));
    }
  }

  Future<void> _onRefreshHome(
    RefreshHome event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;

      final products = await getProductsUseCase.call(
        category: current.selectedCategory,
      );
      final productList = products.fold<List<Product>>(
        (_) => current.products,
        (list) => list,
      );

      UserProfile? user = current.userProfile;
      if (_uid.isNotEmpty) {
        final userProfile = await getUserProfileUseCase.call(_uid);
        userProfile.fold((_) {}, (profile) => user = profile);
      }

      emit(HomeLoaded(
        products: productList,
        userProfile: user,
        selectedCategory: current.selectedCategory,
      ));
    } else {
      add(const LoadHome());
    }
  }
}
