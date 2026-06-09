import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopease/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:shopease/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:shopease/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_event.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final GoogleSignInUseCase googleSignInUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.googleSignInUseCase,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInUseCase.repository.getCurrentUser();
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) => user != null ? emit(Authenticated(user)) : emit(const Unauthenticated()),
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signUpUseCase(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await googleSignInUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await signInUseCase.repository.signOut();
    emit(const Unauthenticated());
  }
}
