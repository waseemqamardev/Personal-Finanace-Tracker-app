import 'package:flutter/material.dart';
import 'package:peronaltracker/core/constants/app_colors.dart';
import 'package:peronaltracker/core/utils/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_providers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterState(),
      child: const _RegisterScreenContent(),
    );
  }
}

class _RegisterScreenContent extends StatelessWidget {
  const _RegisterScreenContent();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.responsivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
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
              children: [
                // Header
                Icon(
                  Icons.person_add,
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
                  'Create Account',
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
                  'Sign up to start managing your finances',
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

                // Register Form
                const _RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    return Consumer2<RegisterState, AuthProvider>(
      builder: (context, registerState, auth, child) {
        return Form(
          key: registerState.formKey,
          child: Column(
            children: [
              CustomInputField(
                controller: registerState.nameController,
                label: 'Full Name',
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: registerState.emailController,
                label: 'Email',
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: registerState.passwordController,
                label: 'Password',
                validator: Validators.validatePassword,
                obscure: registerState.obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    registerState.obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => registerState.togglePasswordVisibility(),
                ),
              ),
              const SizedBox(height: 24),

              // Register Button
              CustomButton(
                text: 'Create Account',
                loading: registerState.loading,
                onPressed: () => _handleRegister(context, registerState, auth),
              ),
              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
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
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: Text(
                      "Sign In",
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

  Future<void> _handleRegister(BuildContext context, RegisterState registerState, AuthProvider auth) async {
    if (!registerState.formKey.currentState!.validate()) return;

    registerState.setLoading(true);

    final token = await auth.register(
      registerState.nameController.text.trim(),
      registerState.emailController.text.trim(),
      registerState.passwordController.text.trim(),
    );

    registerState.setLoading(false);

    if (token != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Email may already exist.')),
      );
    }
  }
}

class RegisterState with ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}