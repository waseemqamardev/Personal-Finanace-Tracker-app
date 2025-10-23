import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input_field.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? editTx;
  const AddEditTransactionScreen({super.key, this.editTx});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _amountC = TextEditingController();
  String _type = 'expense';
  String _category = 'General';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.editTx != null) {
      _titleC.text = widget.editTx!.title;
      _amountC.text = widget.editTx!.amount.toStringAsFixed(2);
      _type = widget.editTx!.type;
      _category = widget.editTx!.category;
      _date = DateTime.parse(widget.editTx!.date);
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _amountC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final txProv = context.read<TransactionProvider>();
    final tx = TransactionModel(
      id: widget.editTx?.id,
      title: _titleC.text.trim(),
      amount: double.parse(_amountC.text.trim()),
      category: _category,
      date: _date.toIso8601String(),
      type: _type,
      userId: 1, // In a real app, this would be the logged-in user's ID
    );

    if (widget.editTx == null) {
      await txProv.addTransaction(tx);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
      }
    } else {
      await txProv.updateTransaction(tx);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated successfully')),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _delete() async {
    if (widget.editTx == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final txProv = context.read<TransactionProvider>();
      await txProv.deleteTransaction(widget.editTx!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editTx == null ? 'Add Transaction' : 'Edit Transaction'),
        actions: [
          if (widget.editTx != null)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Transaction',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.responsivePadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputField(
                controller: _titleC,
                label: 'Title',
                validator: Validators.validateTitle,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _amountC,
                label: 'Amount',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: 16),

              // Transaction Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text('Expense'),
                              leading: Radio(
                                value: 'expense',
                                groupValue: _type,
                                onChanged: (v) => setState(() => _type = v as String),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Income'),
                              leading: Radio(
                                value: 'income',
                                groupValue: _type,
                                onChanged: (v) => setState(() => _type = v as String),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _category,
                        items: ['General', 'Food', 'Transport', 'Shopping', 'Entertainment', 'Healthcare', 'Salary', 'Investment']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v ?? 'General'),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            DateFormat.yMMMMd().format(_date),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _pickDate,
                            child: const Text('Change Date'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              CustomButton(
                text: widget.editTx == null ? 'Add Transaction' : 'Update Transaction',
                onPressed: _save,
              ),

              if (isMobile) const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}