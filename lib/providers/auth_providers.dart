// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import '../core/db/database_helper.dart';
// import '../core/models/user_model.dart';
//
// class AuthProvider extends ChangeNotifier {
//   UserModel? _user;
//   bool get isLoggedIn => _user != null;
//   UserModel? get user => _user;
//
//   Future<Database> get _db async => (await DatabaseHelper.instance.database);
//
//   Future<String?> register(String name, String email, String password) async {
//     final db = await _db;
//     try {
//       final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
//       final id = await db.insert('users', UserModel(name: name, email: email, password: password, token: token).toMap());
//       if (id > 0) {
//         return token;
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }
//
//   Future<bool> login(String email, String password) async {
//     final db = await _db;
//     final res = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
//     if (res.isNotEmpty) {
//       _user = UserModel.fromMap(res.first);
//       _user!.token = 'token_${_user!.id}_${DateTime.now().millisecondsSinceEpoch}';
//       await db.update('users', _user!.toMap(), where: 'id = ?', whereArgs: [_user!.id]);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   Future<void> logout() async {
//     _user = null;
//     notifyListeners();
//   }
//
//   Future<bool> updateProfile({required String name, required String email, String? avatar}) async {
//     if (_user == null) return false;
//     final db = await _db;
//     _user!.name = name;
//     _user!.email = email;
//     _user!.avatar = avatar;
//     await db.update('users', _user!.toMap(), where: 'id = ?', whereArgs: [_user!.id]);
//     notifyListeners();
//     return true;
//   }
// }



import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/db/database_helper.dart';
import '../core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<Database> get _db async => (await DatabaseHelper.instance.database);

  /// 🔹 REGISTER (SQLite + Supabase)
  Future<String?> register(String name, String email, String password) async {
    final db = await _db;
    try {
      final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserModel(
        name: name,
        email: email,
        password: password,
        token: token,
      );

      // Save locally in SQLite
      final id = await db.insert('users', user.toMap());
      user.id = id;
      _user = user;

      // Sign up on Supabase
      try {
        await _supabase.auth.signUp(email: email, password: password);
        debugPrint('✅ Registered on Supabase: $email');
      } catch (e) {
        debugPrint('⚠️ Supabase register failed: $e');
      }

      await _saveSupabaseSession();
      notifyListeners();
      return token;
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      return null;
    }
  }

  /// 🔹 LOGIN (SQLite + Supabase)
  Future<bool> login(String email, String password) async {
    final db = await _db;

    // 🔹 Check local credentials
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (res.isNotEmpty) {
      _user = UserModel.fromMap(res.first);

      // ✅ Try Supabase sign-in
      try {
        final resSupa = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (resSupa.user != null) {
          debugPrint('✅ Supabase login successful: ${resSupa.user!.email}');
          await _saveSupabaseSession();
        }
      } catch (e) {
        debugPrint('❌ Supabase login error: $e');
      }

      notifyListeners();
      return true;
    }

    debugPrint('❌ Invalid local credentials');
    return false;
  }

  /// 🔹 LOGOUT - Clear everything properly
  /// 🔹 LOGOUT - Clear tokens but keep user data
  Future<void> logout() async {
    try {
      // Clear Supabase session
      await _supabase.auth.signOut();
      await _storage.delete(key: 'supabase_session');

      // Clear tokens from SQLite
      await DatabaseHelper.instance.clearUserTokens();

      // Clear the current user instance
      _user = null;

      debugPrint('✅ Logout successful - tokens cleared, user data preserved');
    } catch (e) {
      debugPrint('⚠️ Logout error: $e');
    } finally {
      notifyListeners();
    }
  }
  /// 🔹 UPDATE PROFILE (Local + Supabase)
  Future<bool> updateProfile({
    required String name,
    String? avatar,
  }) async {
    if (_user == null) return false;
    final db = await _db;

    _user!
      ..name = name
      ..avatar = avatar;

    await db.update('users', _user!.toMap(),
        where: 'id = ?', whereArgs: [_user!.id]);

    try {
      final supaUser = _supabase.auth.currentUser;
      if (supaUser != null) {
        await _supabase.from('profiles').upsert({
          'id': supaUser.id,
          'name': name,
          'avatar_url': avatar,
          'updated_at': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Supabase profile updated for ${supaUser.email}');
      }
    } catch (e) {
      debugPrint('⚠️ Supabase profile update failed: $e');
    }

    notifyListeners();
    return true;
  }

  /// 🔹 Save Supabase session securely
  Future<void> _saveSupabaseSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _storage.write(
          key: 'supabase_session',
          value: session.persistSessionString,
        );
        debugPrint('💾 Supabase session saved securely.');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to save Supabase session: $e');
    }
  }

  /// 🔹 Auto Restore Session
  AuthProvider() {
    _restoreSupabaseSession();
  }

  Future<void> _restoreSupabaseSession() async {
    try {
      final savedSession = await _storage.read(key: 'supabase_session');
      if (savedSession != null) {
        debugPrint('🔁 Restoring Supabase session...');
        final res = await _supabase.auth.recoverSession(savedSession);
        if (res.session != null) {
          debugPrint('✅ Session restored for ${res.session!.user.email}');
        }
      }
    } catch (e) {
      debugPrint('❌ Session restore failed: $e');
    }
  }
}
