import 'package:flutter/material.dart';
import 'package:peronaltracker/core/theme/app_theme.dart';
import 'package:peronaltracker/core/utils/notification_service.dart';
import 'package:peronaltracker/providers/auth_providers.dart';
import 'package:peronaltracker/providers/profile_provider.dart';
import 'package:peronaltracker/providers/transaction_provider.dart';
import 'package:peronaltracker/screens/auth/login_screen.dart';
import 'package:peronaltracker/screens/home_screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_key.dart';
import 'core/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseKeys.supabaseUrl,
    anonKey: SupabaseKeys.supabaseAnonKey,
  );

  // Initialize notifications
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Personal Finance Tracker',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Show loading indicator while checking auth state
        if (auth.user == null && !auth.isLoggedIn) {
          return const LoginScreen();
        }

        return const HomeScreen();
      },
    );
  }
}