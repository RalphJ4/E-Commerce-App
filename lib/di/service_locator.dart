import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:shopease/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shopease/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopease/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopease/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:shopease/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:shopease/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:shopease/features/home/data/datasources/home_remote_datasource.dart';
import 'package:shopease/features/home/data/repositories/home_repository_impl.dart';
import 'package:shopease/features/home/domain/repositories/home_repository.dart';
import 'package:shopease/features/home/domain/usecases/get_products_usecase.dart';
import 'package:shopease/features/home/domain/usecases/get_user_profile_usecase.dart';
import 'package:shopease/features/home/presentation/bloc/home_bloc.dart';

import 'package:shopease/features/product_detail/data/datasources/product_detail_remote_datasource.dart';
import 'package:shopease/features/product_detail/data/repositories/product_detail_repository_impl.dart';
import 'package:shopease/features/product_detail/domain/repositories/product_detail_repository.dart';
import 'package:shopease/features/product_detail/domain/usecases/get_product_detail_usecase.dart';
import 'package:shopease/features/product_detail/domain/usecases/add_to_cart_usecase.dart';
import 'package:shopease/features/product_detail/presentation/bloc/product_detail_bloc.dart';

import 'package:shopease/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:shopease/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopease/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopease/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopease/features/cart/domain/usecases/update_cart_item_usecase.dart';
import 'package:shopease/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:shopease/features/cart/presentation/bloc/cart_bloc.dart';

import 'package:shopease/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:shopease/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:shopease/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:shopease/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:shopease/features/checkout/presentation/bloc/checkout_bloc.dart';

import 'package:shopease/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:shopease/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:shopease/features/profile/domain/repositories/profile_repository.dart';
import 'package:shopease/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:shopease/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:shopease/features/profile/domain/usecases/get_order_history_usecase.dart';
import 'package:shopease/features/profile/presentation/bloc/profile_bloc.dart';

import 'package:shopease/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:shopease/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:shopease/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:shopease/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:shopease/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

import 'package:shopease/features/search/data/datasources/search_remote_datasource.dart';
import 'package:shopease/features/search/data/repositories/search_repository_impl.dart';
import 'package:shopease/features/search/domain/repositories/search_repository.dart';
import 'package:shopease/features/search/domain/usecases/search_products_usecase.dart';
import 'package:shopease/features/search/presentation/bloc/search_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  _initAuth();
  _initHome();
  _initProductDetail();
  _initCart();
  _initCheckout();
  _initProfile();
  _initLeaderboard();
  _initSearch();
}

void _initAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        googleSignInUseCase: sl(),
      ));
}

void _initHome() {
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerFactory(() => HomeBloc(
        getProductsUseCase: sl(),
        getUserProfileUseCase: sl(),
      ));
}

void _initProductDetail() {
  sl.registerLazySingleton<ProductDetailRemoteDataSource>(
    () => ProductDetailRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ProductDetailRepository>(
    () => ProductDetailRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProductDetailUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerFactory(() => ProductDetailBloc(
        getProductDetailUseCase: sl(),
        addToCartUseCase: sl(),
      ));
}

void _initCart() {
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerFactory(() => CartBloc(
        getCartUseCase: sl(),
        updateCartItemUseCase: sl(),
        removeFromCartUseCase: sl(),
      ));
}

void _initCheckout() {
  sl.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => PlaceOrderUseCase(sl()));
  sl.registerFactory(() => CheckoutBloc(placeOrderUseCase: sl()));
}

void _initProfile() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderHistoryUseCase(sl()));
  sl.registerFactory(() => ProfileBloc(
        getProfileUseCase: sl(),
        updateAvatarUseCase: sl(),
        getOrderHistoryUseCase: sl(),
      ));
}

void _initLeaderboard() {
  sl.registerLazySingleton<LeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetLeaderboardUseCase(sl()));
  sl.registerFactory(() => LeaderboardBloc(getLeaderboardUseCase: sl()));
}

void _initSearch() {
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerFactory(() => SearchBloc(searchProductsUseCase: sl()));
}
