import 'package:flutter/material.dart';
import 'package:peronaltracker/core/constants/app_colors.dart';
import 'package:peronaltracker/core/utils/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_providers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginState(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatelessWidget {
  const _LoginScreenContent();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.responsivePadding(context);

    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.responsiveValue(
              context,
              mobile: 400,
              tablet: 500,
              desktop: 600,
            ),
          ),
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Icon(
                  Icons.account_balance_wallet,
                  size: ResponsiveUtils.responsiveValue(
                    context,
                    mobile: 60,
                    tablet: 70,
                    desktop: 80,
                  ),
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                      context,
                      mobile: 24,
                      tablet: 26,
                      desktop: 28,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue tracking your finances',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Login Form
                const _LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoginState, AuthProvider>(
      builder: (context, loginState, auth, child) {
        return Form(
          key: loginState.formKey,
          child: Column(
            children: [
              CustomInputField(
                controller: loginState.emailController,
                label: 'Email',
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: loginState.passwordController,
                label: 'Password',
                validator: Validators.validatePassword,
                obscure: loginState.obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    loginState.obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => loginState.togglePasswordVisibility(),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Sign In',
                loading: loginState.loading,
                onPressed: () => _handleLogin(context, loginState, auth),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 15,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogin(BuildContext context, LoginState loginState, AuthProvider auth) async {
    if (!loginState.formKey.currentState!.validate()) return;

    loginState.setLoading(true);

    final ok = await auth.login(
      loginState.emailController.text.trim(),
      loginState.passwordController.text.trim(),
    );

    loginState.setLoading(false);

    if (ok && context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }
}

class LoginState with ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  bool get loading => _loading;
  bool get obscurePassword => _obscurePassword;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}