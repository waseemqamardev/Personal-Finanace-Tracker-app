import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/db/database_helper.dart';
import '../core/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;
  final _supabase = Supabase.instance.client;

  Future<Database> get _db async => (await DatabaseHelper.instance.database);

  Future<void> loadTransactions() async {
    final db = await _db;
    final maps = await db.query('transactions', orderBy: 'date DESC', limit: 100);
    _transactions = maps.map((m) => TransactionModel.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final db = await _db;
    final id = await db.insert('transactions', tx.toMap());
    tx.id = id;
    _transactions.insert(0, tx);
    await _uploadToSupabase(tx);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final db = await _db;
    await db.update('transactions', tx.toMap(), where: 'id = ?', whereArgs: [tx.id]);
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index >= 0) _transactions[index] = tx;
    await _uploadToSupabase(tx);
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _db;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  double totalIncome() =>
      _transactions.where((t) => t.type == 'income').fold(0.0, (p, e) => p + e.amount);

  double totalExpense() =>
      _transactions.where((t) => t.type == 'expense').fold(0.0, (p, e) => p + e.amount);

  double get balance => totalIncome() - totalExpense();

  Future<void> _uploadToSupabase(TransactionModel tx) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        debugPrint('⚠️ No Supabase user found. Skipping sync for ${tx.title}');
        return;
      }

      final existing = await _supabase
          .from('expenses')
          .select()
          .eq('user_email', user.email)
          .eq('title', tx.title)
          .eq('date', tx.date)
          .limit(1)
          .execute();

      if (existing.data != null && (existing.data as List).isNotEmpty) {
        debugPrint('Transaction already exists in Supabase: ${tx.title}');
        return;
      }

      await _supabase.from('expenses').insert({
        'title': tx.title,
        'amount': tx.amount,
        'category': tx.category,
        'date': tx.date,
        'user_email': user.email,
      });

      debugPrint('Supabase Upload Success: ${tx.title}');
    } catch (e) {
      debugPrint(' Supabase sync failed for ${tx.title}: $e');
    }
  }

  Future<void> syncAllExpensesToSupabase() async {
    debugPrint(' Starting bulk sync to Supabase...');
    for (var tx in _transactions.where((t) => t.type == 'expense')) {
      await _uploadToSupabase(tx);
    }
    debugPrint('All expense transactions synced!');
  }
}
