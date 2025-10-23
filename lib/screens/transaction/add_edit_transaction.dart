import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

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
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) setState(() => _date = d);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    final tx = TransactionModel(
      id: widget.editTx?.id,
      title: _titleC.text.trim(),
      amount: double.parse(_amountC.text.trim()),
      category: _category,
      date: _date.toIso8601String(),
      type: _type,
      userId: 1,
    );
    if (widget.editTx == null) {
      await txProv.addTransaction(tx);
    } else {
      await txProv.updateTransaction(tx);
    }
    Navigator.pop(context);
  }

  void _delete() async {
    if (widget.editTx == null) return;
    final txProv = Provider.of<TransactionProvider>(context, listen: false);
    await txProv.deleteTransaction(widget.editTx!.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.editTx == null ? 'Add Transaction' : 'Edit Transaction'), actions: [
        if (widget.editTx != null) IconButton(onPressed: _delete, icon: const Icon(Icons.delete))
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(controller: _titleC, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v != null && v.isNotEmpty ? null : 'Enter title'),
            TextFormField(controller: _amountC, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number, validator: (v) => v != null && double.tryParse(v) != null ? null : 'Enter valid amount'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: ListTile(title: const Text('Expense'), leading: Radio(value: 'expense', groupValue: _type, onChanged: (v) => setState(() => _type = v as String)))),
              Expanded(child: ListTile(title: const Text('Income'), leading: Radio(value: 'income', groupValue: _type, onChanged: (v) => setState(() => _type = v as String)))),
            ]),
            DropdownButtonFormField<String>(value: _category, items: ['General', 'Food', 'Transport', 'Shopping', 'Salary'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _category = v ?? 'General')),
            const SizedBox(height: 8),
            Row(children: [Text('Date: ${DateFormat.yMd().format(_date)}'), TextButton(onPressed: _pickDate, child: const Text('Pick'))]),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ]),
        ),
      ),
    );
  }
}
