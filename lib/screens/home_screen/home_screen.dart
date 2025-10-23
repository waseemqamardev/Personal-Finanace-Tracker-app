import 'package:flutter/material.dart';
import 'package:peronaltracker/core/utils/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../widgets/pie_chart_widget.dart';
import '../../../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  Future<void> _refresh() async {
    await context.read<TransactionProvider>().loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
          ),
        ],
      ),

      body: Consumer<TransactionProvider>(
        builder: (context, txProv, child) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildContent(context, txProv, isMobile),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
        child: const Icon(Icons.add),
        tooltip: 'Add Transaction',
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionProvider txProv, bool isMobile) {
    final income = txProv.totalIncome();
    final expense = txProv.totalExpense();
    final balance = txProv.balance;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: ResponsiveUtils.responsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  isMobile
                      ? _buildMobileSummary(income, expense, balance)
                      : _buildDesktopSummary(income, expense, balance),

                  const SizedBox(height: 24),

                  // Charts and Transactions
                  isMobile
                      ? _buildMobileContent(txProv)
                      : _buildDesktopContent(txProv),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileSummary(double income, double expense, double balance) {
    return Column(
      children: [
        _buildSummaryCard('Income', income, Colors.green, Icons.arrow_upward),
        const SizedBox(height: 12),
        _buildSummaryCard('Expense', expense, Colors.red, Icons.arrow_downward),
        const SizedBox(height: 12),
        _buildSummaryCard('Balance', balance, Colors.blue, Icons.account_balance_wallet),
      ],
    );
  }

  Widget _buildDesktopSummary(double income, double expense, double balance) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Income', income, Colors.green, Icons.arrow_upward)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Expense', expense, Colors.red, Icons.arrow_downward)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Balance', balance, Colors.blue, Icons.account_balance_wallet)),
      ],
    );
  }

  Widget _buildSummaryCard(String label, double value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContent(TransactionProvider txProv) {
    return Column(
      children: [
        const PieChartWidget(),
        const SizedBox(height: 24),
        _buildTransactionSection(txProv),
      ],
    );
  }

  Widget _buildDesktopContent(TransactionProvider txProv) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: const PieChartWidget(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _buildTransactionSection(txProv),
        ),
      ],
    );
  }

  Widget _buildTransactionSection(TransactionProvider txProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (txProv.transactions.isNotEmpty)
              Text(
                '${txProv.transactions.length} total',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                  ),
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (txProv.transactions.isEmpty)
          _buildEmptyState()
        else
          ...txProv.transactions
              .take(10)
              .map((t) => TransactionTile(tx: t))
              .toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first transaction by tapping the + button',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}