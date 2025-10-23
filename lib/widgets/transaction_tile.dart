import 'package:flutter/material.dart';
import '../../core/models/transaction_model.dart';
import '../screens/transaction/add_edit_transaction.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(tx.title),
        subtitle: Text('${tx.category} • ${DateTime.parse(tx.date).toLocal().toString().split(' ')[0]}'),
        trailing: Text((tx.type == 'income' ? '+ ' : '- ') + '\$${tx.amount.toStringAsFixed(2)}', style: TextStyle(color: tx.type == 'income' ? Colors.green : Colors.red)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditTransactionScreen(editTx: tx))),
      ),
    );
  }
}
