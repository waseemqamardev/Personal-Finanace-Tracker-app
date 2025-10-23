import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = await auth.register(_nameC.text.trim(), _emailC.text.trim(), _passC.text.trim());
    setState(() => _loading = false);
    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered. Please login')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed (email may exist)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputField(controller: _nameC, label: 'Name', validator: Validators.validateName),
              CustomInputField(controller: _emailC, label: 'Email', validator: Validators.validateEmail, keyboardType: TextInputType.emailAddress),
              CustomInputField(controller: _passC, label: 'Password', validator: Validators.validatePassword, obscure: true),
              const SizedBox(height: 20),
              CustomButton(text: 'Register', loading: _loading, onPressed: _register),
            ],
          ),
        ),
      ),
    );
  }
}
