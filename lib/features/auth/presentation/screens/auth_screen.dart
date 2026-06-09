import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shopease/core/theme/app_theme.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_event.dart';
import 'package:shopease/features/auth/presentation/bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isSignIn = !_isSignIn);
    _formKey.currentState?.reset();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (_isSignIn) {
      context.read<AuthBloc>().add(
            SignInRequested(email: email, password: password),
          );
    } else {
      final name = _nameController.text.trim();
      context.read<AuthBloc>().add(
            SignUpRequested(
              email: email,
              password: password,
              displayName: name,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                SizedBox(height: 40.h),
                _buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .4),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_bag_rounded,
            size: 48.w,
            color: AppColors.white,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -.5, end: 0, curve: Curves.elasticOut),
        SizedBox(height: 16.h),
        Text(
          'ShopEase',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.white,
                letterSpacing: 1.2,
              ),
        ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: -.3, end: 0),
        SizedBox(height: 4.h),
        Text(
          'Your gamified shopping experience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white60,
              ),
        ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
      ],
    );
  }

  Widget _buildForm() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: _blurFilter(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              color: AppColors.white10,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: AppColors.white.withValues(alpha: .08),
                width: 1,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildToggle(),
                  SizedBox(height: 24.h),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isSignIn
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: _buildNameField(),
                    secondChild: const SizedBox.shrink(),
                  ),
                  _buildEmailField(),
                  SizedBox(height: 16.h),
                  _buildPasswordField(),
                  SizedBox(height: 24.h),
                  _buildSubmitButton(),
                  SizedBox(height: 16.h),
                  _buildDivider(),
                  SizedBox(height: 16.h),
                  _buildGoogleButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: .3, end: 0, curve: Curves.easeOutCubic);
  }

  _blurFilter() {
    return ImageFilter.blur(sigmaX: 20, sigmaY: 20);
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isSignIn ? null : _toggleMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _isSignIn ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isSignIn ? AppColors.white : AppColors.white60,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _isSignIn ? _toggleMode : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: !_isSignIn ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isSignIn ? AppColors.white : AppColors.white60,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          style: TextStyle(color: AppColors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.white60, size: 20.w),
          ),
          validator: (v) {
            if (!_isSignIn && (v == null || v.trim().isEmpty)) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: AppColors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: 'Email Address',
        prefixIcon: Icon(Icons.email_outlined, color: AppColors.white60, size: 20.w),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter your email';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(color: AppColors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.white60, size: 20.w),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.white60,
            size: 20.w,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your password';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          height: 52.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: .5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    _isSignIn ? 'Sign In' : 'Create Account',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.white.withValues(alpha: .1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.white30,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.white.withValues(alpha: .1))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          height: 52.h,
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () => context.read<AuthBloc>().add(const GoogleSignInRequested()),
            icon: Icon(
              Icons.g_mobiledata,
              color: AppColors.white,
              size: 28.w,
            ),
            label: Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.white.withValues(alpha: .2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
