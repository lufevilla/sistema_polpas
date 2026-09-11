import 'package:flutter/material.dart';
import 'package:sistema_polpas/pages/reports/widgets/reports_widgets.dart';
import '../../core/theme/app_colors.dart';
import 'reports_controller.dart';

/// "Relatórios" (Reports) tab.
///
/// Important: just like the other tabs, this page does NOT have its own
/// Scaffold, AppHeader or bottom navigation — it's used as the content
/// of one of the tabs inside the main shell
/// (see lib/features/bottomNavigationBar/bottom_navigation_page.dart),
/// which already takes care of the header and the bottom nav.
///
/// The content is scrollable and, for now, every value comes mocked
/// from ReportsController.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportsController _controller = ReportsController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MetricCard(
                title: 'Faturamento Mensal',
                icon: Icons.payments_outlined,
                iconBackground: AppColors.gold,
                iconColor: AppColors.textDark,
                value: _formatCurrency(_controller.monthlyRevenue),
                variationLabel:
                    '+${_controller.monthlyRevenueVariationPercentage.toStringAsFixed(1)}% vs. mês anterior',
                variationType: _controller.monthlyRevenueVariationType,
              ),
              const SizedBox(height: 16),
              MetricCard(
                title: 'Pedidos Realizados',
                icon: Icons.shopping_cart_outlined,
                iconBackground: const Color(0xFFF3ECE3),
                iconColor: AppColors.headerStart,
                value: '${_controller.ordersCompleted}',
                variationLabel:
                    '+${_controller.ordersVariationPercentage.toStringAsFixed(1)}% vs. mês anterior',
                variationType: _controller.ordersVariationType,
              ),
              const SizedBox(height: 16),
              MetricCard(
                title: 'Ticket Médio',
                icon: Icons.receipt_long_outlined,
                iconBackground: const Color(0xFFF3ECE3),
                iconColor: AppColors.headerStart,
                value: _formatCurrency(_controller.averageTicket),
                variationLabel: 'Estável vs. mês anterior',
                variationType: _controller.averageTicketVariationType,
              ),
              const SizedBox(height: 24),
              FlavorRankingCard(flavors: _controller.topSellingFlavors),
              const SizedBox(height: 16),
              PerformanceChartCard(data: _controller.sixMonthPerformance),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _controller.onStockReportTap,
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  label: const Text('Relatório de Estoque'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.headerStart,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _controller.onExportPdfTap,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: const Text('Exportar PDF'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final cents = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      final positionFromRight = integerPart.length - i;
      buffer.write(integerPart[i]);
      if (positionFromRight > 1 && positionFromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'R\$ $buffer,$cents';
  }
}
