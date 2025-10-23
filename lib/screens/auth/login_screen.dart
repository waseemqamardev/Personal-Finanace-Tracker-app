import 'package:flutter/material.dart';
import 'package:peronaltracker/providers/auth_providers.dart';
import 'package:peronaltracker/screens/home_screen/home_screen.dart';
import 'package:peronaltracker/widgets/custom_button.dart';
import 'package:peronaltracker/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';
import '../../core/utils/validators.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.login(_emailC.text.trim(), _passC.text.trim());
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Login to your account', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 28),
                CustomInputField(controller: _emailC, label: 'Email', validator: Validators.validateEmail, keyboardType: TextInputType.emailAddress),
                CustomInputField(controller: _passC, label: 'Password', validator: Validators.validatePassword, obscure: true),
                const SizedBox(height: 20),
                CustomButton(text: 'Login', loading: _loading, onPressed: _login),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text("Don't have an account? Register"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
