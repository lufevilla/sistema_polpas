import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'stock_controller.dart';
import 'widgets/stock_bestseller_card.dart';
import 'widgets/stock_item_card.dart';
import 'widgets/stock_low_stock_card.dart';
import 'widgets/stock_total_card.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _controller = StockController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(child: _buildSummary()),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = _controller.items[index];
                    return StockItemCard(
                      item: item,
                      onIncrement: () => _controller.increment(item.id),
                      onDecrement: () => _controller.decrement(item.id),
                      onNewBatch: () => _controller.startNewBatch(item.id),
                    );
                  }, childCount: _controller.items.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestão de Estoque',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Polpas Artesanais - 1kg',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.filter_list,
                size: 20,
                color: AppColors.textDark,
              ),
              label: Text(
                'Filtrar',
                style: TextStyle(color: AppColors.textDark),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                side: BorderSide(color: AppColors.border),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: StockTotalCard(total: _controller.totalStock),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StockLowStockCard(count: _controller.lowStockCount),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StockBestsellerCard(name: _controller.bestSellerName),
      ],
    );
  }
}
