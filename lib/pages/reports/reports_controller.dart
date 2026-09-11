import 'package:flutter/material.dart';

/// Type of variation of a metric compared to the previous month.
enum VariationType { positive, negative, stable }

/// One item of the "Sabores Mais Vendidos" (Top Selling Flavors) ranking.
class FlavorRanking {
  final int position;
  final String name;
  final double percentage; // 0-100
  final int unitsSold;

  const FlavorRanking({
    required this.position,
    required this.name,
    required this.percentage,
    required this.unitsSold,
  });
}

/// One data point of the "Desempenho (6 Meses)" (6-Month Performance) chart.
class MonthlyPerformance {
  final String month;
  final double value;

  const MonthlyPerformance({required this.month, required this.value});
}

/// Controller for the Reports tab: mock data only for now.
/// TODO: replace with real values calculated from `pedidos` +
/// `itens_pedido` (revenue, average ticket, top selling flavors, etc),
/// following the same offline-first pattern used in the rest of the app.
class ReportsController extends ChangeNotifier {
  final double monthlyRevenue = 12450.00;
  final double monthlyRevenueVariationPercentage = 12.5;
  final VariationType monthlyRevenueVariationType = VariationType.positive;

  final int ordersCompleted = 84;
  final double ordersVariationPercentage = 5.2;
  final VariationType ordersVariationType = VariationType.positive;

  final double averageTicket = 148.00;
  final VariationType averageTicketVariationType = VariationType.stable;

  final List<FlavorRanking> topSellingFlavors = const [
    FlavorRanking(
      position: 1,
      name: 'Maracujá',
      percentage: 35,
      unitsSold: 320,
    ),
    FlavorRanking(
      position: 2,
      name: 'Frutas Vermelhas',
      percentage: 28,
      unitsSold: 256,
    ),
    FlavorRanking(position: 3, name: 'Acerola', percentage: 22, unitsSold: 201),
  ];

  final List<MonthlyPerformance> sixMonthPerformance = const [
    MonthlyPerformance(month: 'Jan', value: 8200),
    MonthlyPerformance(month: 'Fev', value: 9100),
    MonthlyPerformance(month: 'Mar', value: 7400),
    MonthlyPerformance(month: 'Abr', value: 10800),
    MonthlyPerformance(month: 'Mai', value: 9950),
    MonthlyPerformance(month: 'Jun', value: 12450),
  ];

  // TODO: generate a real stock report (PDF/spreadsheet built from the
  // current stock data).
  void onStockReportTap() {}

  // TODO: export this report (revenue, orders, ranking, etc) as a PDF.
  void onExportPdfTap() {}
}
