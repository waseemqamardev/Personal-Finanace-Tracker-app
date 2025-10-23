import 'package:flutter/material.dart';
import 'package:peronaltracker/core/utils/app_routes.dart';
import '../../core/models/transaction_model.dart';
import '../../core/utils/responsive_utils.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isIncome = tx.type == 'income';

    return Card(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 20,
          vertical: isMobile ? 8 : 12,
        ),
        leading: Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
          decoration: BoxDecoration(
            color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
            size: isMobile ? 20 : 24,
          ),
        ),
        title: Text(
          tx.title,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 16,
              tablet: 17,
            ),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${tx.category} • ${_formatDate(tx.date)}',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 14,
              tablet: 15,
            ),
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '${isIncome ? '+ ' : '- '}\$${tx.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 16,
              tablet: 17,
            ),
            fontWeight: FontWeight.w600,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.editTransaction,
          arguments: tx,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}