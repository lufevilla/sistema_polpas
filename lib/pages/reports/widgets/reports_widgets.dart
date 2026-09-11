import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/reports/reports_controller.dart';

/// Small badge with the variation compared to the previous month
/// (ex: "+12,5% vs. mês anterior" / "Estável vs. mês anterior").
class VariationBadge extends StatelessWidget {
  final String label;
  final VariationType type;

  const VariationBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;

    switch (type) {
      case VariationType.positive:
        bg = const Color(0xFFDFF3E1);
        fg = AppColors.success;
        icon = Icons.trending_up;
        break;
      case VariationType.negative:
        bg = const Color(0xFFF7DEDC);
        fg = AppColors.danger;
        icon = Icons.trending_down;
        break;
      case VariationType.stable:
        bg = const Color(0xFFEFE6D8);
        fg = AppColors.textMuted;
        icon = Icons.arrow_forward;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Metric card (Faturamento Mensal / Pedidos Realizados / Ticket
/// Médio): title, circular icon, highlighted value and variation badge.
class MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String value;
  final String variationLabel;
  final VariationType variationType;

  const MetricCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.value,
    required this.variationLabel,
    required this.variationType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.headerStart,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          VariationBadge(label: variationLabel, type: variationType),
        ],
      ),
    );
  }
}

/// "Sabores Mais Vendidos" (Top Selling Flavors) card: title with icon +
/// ranking (position, name, percentage with progress bar, units sold).
class FlavorRankingCard extends StatelessWidget {
  final List<FlavorRanking> flavors;

  const FlavorRankingCard({super.key, required this.flavors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: AppColors.headerStart),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sabores Mais Vendidos',
                  style: TextStyle(
                    color: AppColors.headerStart,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final flavor in flavors) ...[
            _FlavorRankingTile(flavor: flavor),
            if (flavor != flavors.last) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class _FlavorRankingTile extends StatelessWidget {
  final FlavorRanking flavor;

  const _FlavorRankingTile({required this.flavor});

  @override
  Widget build(BuildContext context) {
    final isFirstPlace = flavor.position == 1;
    final highlightColor = isFirstPlace
        ? AppColors.gold
        : const Color(0xFFB4453A);
    final circleBackground = isFirstPlace
        ? AppColors.gold
        : const Color(0xFFF3DCD9);
    final circleForeground = isFirstPlace
        ? AppColors.textDark
        : AppColors.headerStart;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: circleBackground,
          child: Text(
            '${flavor.position}',
            style: TextStyle(
              color: circleForeground,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      flavor.name,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${flavor.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppColors.headerStart,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: flavor.percentage / 100,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEFE6D8),
                  valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${flavor.unitsSold} unid.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

/// "Desempenho (6 Meses)" (6-Month Performance) card: simple bar chart
/// (no external dependency), with a value axis and months on the X axis.
class PerformanceChartCard extends StatelessWidget {
  final List<MonthlyPerformance> data;

  const PerformanceChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final highestValue = data
        .map((d) => d.value)
        .reduce((a, b) => a > b ? a : b);
    // Rounds the axis ceiling up to the nearest 5k above the highest value.
    final ceiling = ((highestValue / 5000).ceil()) * 5000;
    final scale = [ceiling, ceiling * 3 / 4, ceiling / 2, ceiling / 4, 0.0];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: AppColors.headerStart),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Desempenho (6 Meses)',
                  style: TextStyle(
                    color: AppColors.headerStart,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Value axis (15k, 10k, 5k, 0).
                SizedBox(
                  width: 32,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final value in scale)
                        Text(
                          value >= 1000
                              ? '${(value / 1000).toStringAsFixed(0)}k'
                              : value.toStringAsFixed(0),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Bars.
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final point in data)
                        _MonthBar(
                          point: point,
                          relativeHeight: ceiling == 0
                              ? 0
                              : point.value / ceiling,
                          isLast: point == data.last,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final MonthlyPerformance point;
  final double relativeHeight;
  final bool isLast;

  const _MonthBar({
    required this.point,
    required this.relativeHeight,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: relativeHeight.clamp(0.02, 1.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isLast ? AppColors.headerStart : AppColors.gold,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            point.month,
            style: TextStyle(
              color: isLast ? AppColors.headerStart : AppColors.textMuted,
              fontSize: 11,
              fontWeight: isLast ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
