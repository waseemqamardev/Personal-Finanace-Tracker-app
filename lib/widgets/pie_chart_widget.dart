import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:peronaltracker/core/models/transaction_model.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  bool showExpense = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, txProv, child) {
        final expenses = txProv.transactions.where((t) => t.type == 'expense').toList();
        final incomes = txProv.transactions.where((t) => t.type == 'income').toList();

        final hasExpenses = expenses.isNotEmpty;
        final hasIncomes = incomes.isNotEmpty;
        final showToggle = hasExpenses && hasIncomes;
        final showExpenseActual = showToggle ? showExpense : hasExpenses;

        final transactions = showExpenseActual ? expenses : incomes;

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        final categoryTotals = _calculateCategoryTotals(transactions);
        final total = categoryTotals.values.fold(0.0, (p, e) => p + e);
        final sections = _buildChartSections(categoryTotals, total, showExpenseActual);

        return _buildChartContainer(context, showToggle, showExpenseActual, sections, categoryTotals);
      },
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pie_chart, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No data available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List<TransactionModel> transactions) {
    final Map<String, double> categoryTotals = {};
    for (var tx in transactions) {
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
    }
    return categoryTotals;
  }

  List<PieChartSectionData> _buildChartSections(
      Map<String, double> categoryTotals, double total, bool showExpenseActual) {
    final colors = showExpenseActual
        ? [
      const Color(0xFFE57373),
      const Color(0xFFFF8A65),
      const Color(0xFFBA68C8),
      const Color(0xFFFFB74D),
      const Color(0xFF4DB6AC),
      const Color(0xFF7986CB),
    ]
        : [
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFF4DD0E1),
      const Color(0xFFAED581),
      const Color(0xFFFFD54F),
      const Color(0xFF4FC3F7),
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = [];

    categoryTotals.forEach((category, amount) {
      final percent = (amount / total) * 100;
      final color = colors[colorIndex % colors.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          radius: 55,
          title: '${percent.toStringAsFixed(1)}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          titlePositionPercentageOffset: 0.55,
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  Widget _buildChartContainer(
      BuildContext context,
      bool showToggle,
      bool showExpenseActual,
      List<PieChartSectionData> sections,
      Map<String, double> categoryTotals) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final chartSize = ResponsiveUtils.responsiveValue(
      context,
      mobile: 200,
      tablet: 250,
      desktop: 280,
    );

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 20 : 24,
          horizontal: isMobile ? 16 : 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    showExpenseActual ? 'Expense Breakdown' : 'Income Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                      ),
                      color: AppColors.primary,
                    ),
                  ),
                  if (showToggle)
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(value: true, label: Text('Expense')),
                        ButtonSegment<bool>(value: false, label: Text('Income')),
                      ],
                      selected: <bool>{showExpense},
                      onSelectionChanged: (val) {
                        setState(() => showExpense = val.first);
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Animated Pie Chart
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: SizedBox(
                key: ValueKey(showExpenseActual),
                height: chartSize,
                width: chartSize,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: chartSize * 0.25,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                    startDegreeOffset: -90,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 800),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Legend
            _buildLegend(context, categoryTotals, showExpenseActual),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Map<String, double> categoryTotals, bool showExpenseActual) {
    final colors = showExpenseActual
        ? [
      const Color(0xFFE57373),
      const Color(0xFFFF8A65),
      const Color(0xFFBA68C8),
      const Color(0xFFFFB74D),
      const Color(0xFF4DB6AC),
      const Color(0xFF7986CB),
    ]
        : [
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFF4DD0E1),
      const Color(0xFFAED581),
      const Color(0xFFFFD54F),
      const Color(0xFF4FC3F7),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: categoryTotals.entries.map((entry) {
        final color = colors[categoryTotals.keys.toList().indexOf(entry.key) % colors.length];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${entry.key} (\$${entry.value.toStringAsFixed(2)})',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                  ),
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}