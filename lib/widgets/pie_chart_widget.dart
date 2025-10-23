import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/constants/app_colors.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  bool showExpense = true;

  @override
  // Widget build(BuildContext context) {
  //   final txProv = Provider.of<TransactionProvider>(context);
  //   final transactions = txProv.transactions
  //       .where((t) => t.type == (showExpense ? 'expense' : 'income'))
  //       .toList();
  //
  //   if (transactions.isEmpty) {
  //     return Card(
  //       elevation: 3,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       child: const Padding(
  //         padding: EdgeInsets.all(30),
  //         child: Center(
  //           child: Text(
  //             'No data available',
  //             style: TextStyle(fontSize: 16, color: Colors.grey),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //
  //   // 🔹 Group transactions by category
  //   final Map<String, double> categoryTotals = {};
  //   for (var tx in transactions) {
  //     categoryTotals[tx.category] =
  //         (categoryTotals[tx.category] ?? 0) + tx.amount;
  //   }
  //
  //   final total = categoryTotals.values.fold(0.0, (p, e) => p + e);
  //
  //   // 🔹 Dynamic color palette
  //   final colors = showExpense
  //       ? [
  //           const Color(0xFFE57373),
  //           const Color(0xFFFF8A65),
  //           const Color(0xFFBA68C8),
  //           const Color(0xFFFFB74D),
  //           const Color(0xFF4DB6AC),
  //           const Color(0xFF7986CB),
  //         ]
  //       : [
  //           const Color(0xFF81C784),
  //           const Color(0xFF64B5F6),
  //           const Color(0xFF4DD0E1),
  //           const Color(0xFFAED581),
  //           const Color(0xFFFFD54F),
  //           const Color(0xFF4FC3F7),
  //         ];
  //
  //   int colorIndex = 0;
  //   final List<PieChartSectionData> sections = [];
  //
  //   categoryTotals.forEach((category, amount) {
  //     final percent = (amount / total) * 100;
  //     final color = colors[colorIndex % colors.length];
  //     sections.add(
  //       PieChartSectionData(
  //         color: color,
  //         value: amount,
  //         radius: 55,
  //         title: '${percent.toStringAsFixed(1)}%',
  //         titleStyle: const TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.bold,
  //           fontSize: 13,
  //         ),
  //         titlePositionPercentageOffset: 0.55,
  //       ),
  //     );
  //     colorIndex++;
  //   });
  //
  //   // ✅ Responsive & Overflow-safe Layout
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final screenWidth = MediaQuery.of(context).size.width;
  //       final chartSize =
  //           (screenWidth < 400 ? screenWidth * 0.65 : screenWidth * 0.45)
  //               .clamp(180, 280)
  //               .toDouble();
  //
  //       return Card(
  //         elevation: 5,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // 🔹 Header with Toggle (overflow-safe)
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                 child: Wrap(
  //                   alignment: WrapAlignment.spaceBetween,
  //                   crossAxisAlignment: WrapCrossAlignment.center,
  //                   spacing: 8,
  //                   runSpacing: 8,
  //                   children: [
  //                     Text(
  //                       showExpense ? 'Expense Breakdown' : 'Income Breakdown',
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 18,
  //                         color: AppColors.primary,
  //                       ),
  //                     ),
  //                     SegmentedButton<bool>(
  //                       segments: const [
  //                         ButtonSegment<bool>(
  //                             value: true, label: Text('Expense')),
  //                         ButtonSegment<bool>(
  //                             value: false, label: Text('Income')),
  //                       ],
  //                       selected: <bool>{showExpense},
  //                       onSelectionChanged: (val) {
  //                         setState(() => showExpense = val.first);
  //                       },
  //                       style: ButtonStyle(
  //                         visualDensity: VisualDensity.compact,
  //                         padding: MaterialStateProperty.all(
  //                           const EdgeInsets.symmetric(horizontal: 8),
  //                         ),
  //                         backgroundColor:
  //                             MaterialStateProperty.resolveWith((states) {
  //                           if (states.contains(MaterialState.selected)) {
  //                             return AppColors.primary.withOpacity(0.15);
  //                           }
  //                           return Colors.transparent;
  //                         }),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 20),
  //
  //               // 🔹 Animated Pie Chart (Responsive)
  //               AnimatedSwitcher(
  //                 duration: const Duration(milliseconds: 600),
  //                 transitionBuilder: (child, anim) =>
  //                     ScaleTransition(scale: anim, child: child),
  //                 child: SizedBox(
  //                   key: ValueKey(showExpense),
  //                   height: chartSize,
  //                   width: chartSize,
  //                   child: PieChart(
  //                     PieChartData(
  //                       sections: sections,
  //                       centerSpaceRadius: chartSize * 0.25,
  //                       sectionsSpace: 2,
  //                       borderData: FlBorderData(show: false),
  //                       startDegreeOffset: -90,
  //                     ),
  //                     swapAnimationDuration: const Duration(milliseconds: 800),
  //                     swapAnimationCurve: Curves.easeOutCubic,
  //                   ),
  //                 ),
  //               ),
  //
  //               const SizedBox(height: 20),
  //
  //               // 🔹 Dynamic & Responsive Legend
  //               LayoutBuilder(
  //                 builder: (context, legendConstraints) {
  //                   final isSmallScreen =
  //                       MediaQuery.of(context).size.width < 360;
  //                   return Wrap(
  //                     alignment: WrapAlignment.center,
  //                     spacing: 8,
  //                     runSpacing: 6,
  //                     children: categoryTotals.entries.map((entry) {
  //                       final color = colors[
  //                           categoryTotals.keys.toList().indexOf(entry.key) %
  //                               colors.length];
  //                       return Container(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 8, vertical: 4),
  //                         decoration: BoxDecoration(
  //                           color: color.withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(20),
  //                         ),
  //                         child: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Container(
  //                               width: 10,
  //                               height: 10,
  //                               decoration: BoxDecoration(
  //                                 shape: BoxShape.circle,
  //                                 color: color,
  //                               ),
  //                             ),
  //                             const SizedBox(width: 6),
  //                             Text(
  //                               '${entry.key} (${entry.value.toStringAsFixed(2)})',
  //                               style: TextStyle(
  //                                 fontSize: isSmallScreen ? 11 : 13,
  //                                 color: Colors.grey[800],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     }).toList(),
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
// }
  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionProvider>(context);
    final expenses = txProv.transactions.where((t) => t.type == 'expense')
        .toList();
    final incomes = txProv.transactions.where((t) => t.type == 'income')
        .toList();

    // Decide which type to show
    final hasExpenses = expenses.isNotEmpty;
    final hasIncomes = incomes.isNotEmpty;

    // If both exist, use the toggle to switch, else default to the one that exists
    final showToggle = hasExpenses && hasIncomes;
    final showExpenseActual = showToggle ? showExpense : hasExpenses;

    final transactions = showExpenseActual ? expenses : incomes;

    if (transactions.isEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // 🔹 Group transactions by category
    final Map<String, double> categoryTotals = {};
    for (var tx in transactions) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    final total = categoryTotals.values.fold(0.0, (p, e) => p + e);

    // 🔹 Dynamic color palette
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery
            .of(context)
            .size
            .width;
        final chartSize =
        (screenWidth < 400 ? screenWidth * 0.65 : screenWidth * 0.45)
            .clamp(180, 280)
            .toDouble();

        return Card(
          elevation: 5,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        showExpenseActual
                            ? 'Expense Breakdown'
                            : 'Income Breakdown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      if (showToggle)
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                                value: true, label: Text('Expense')),
                            ButtonSegment<bool>(
                                value: false, label: Text('Income')),
                          ],
                          selected: <bool>{showExpense},
                          onSelectionChanged: (val) {
                            setState(() => showExpense = val.first);
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            backgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return AppColors.primary.withOpacity(0.15);
                              }
                              return Colors.transparent;
                            }),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Animated Pie Chart
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
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
                      swapAnimationCurve: Curves.easeOutCubic,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Legend
                LayoutBuilder(
                  builder: (context, legendConstraints) {
                    final isSmallScreen =
                        MediaQuery
                            .of(context)
                            .size
                            .width < 360;
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: categoryTotals.entries.map((entry) {
                        final color = colors[
                        categoryTotals.keys.toList().indexOf(entry.key) %
                            colors.length];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                                '${entry.key} (${entry.value.toStringAsFixed(
                                    2)})',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}