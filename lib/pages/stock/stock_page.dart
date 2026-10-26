import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'stock_controller.dart';
import 'widgets/stock_bestseller_card.dart';
import 'widgets/stock_form_modal.dart';
import 'widgets/stock_item_card.dart';
import 'widgets/stock_low_stock_card.dart';
import 'widgets/stock_movimento_modal.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _controller = StockController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_aoControladorMudar);
    _controller.carregarEstoque();
  }

  @override
  void dispose() {
    _controller.removeListener(_aoControladorMudar);
    _controller.dispose();
    super.dispose();
  }

  void _aoControladorMudar() => setState(() {});

  void _abrirModalNovoItem() {
    mostrarModalNovoItemEstoque(
      context: context,
      aoSalvar: (produto) {
        _controller.incluirItem(produto);
      },
    );
  }

  void _abrirModalEntrada(Produto produto) {
    mostrarModalEntradaEstoque(
      context: context,
      produto: produto,
      aoSalvar: (quantidade, valorUnitario) {
        _controller.registrarEntrada(
          produto: produto,
          quantidade: quantidade,
          valorUnitario: valorUnitario,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.carregando) {
      return Container(
        color: AppColors.background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller.erro.isNotEmpty) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                const SizedBox(height: 16),
                Text(
                  _controller.erro,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _controller.carregarEstoque,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildSummary()),
          ),
          if (_controller.items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    'Nenhum item no estoque.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final produto = _controller.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StockItemCard(
                      produto: produto,
                      onEntrada: () => _abrirModalEntrada(produto),
                      onDecrement: () => _controller.decrement(produto),
                    ),
                  );
                }, childCount: _controller.items.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirModalNovoItem,
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.textDark,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StockLowStockCard(count: _controller.lowStockCount),
        const SizedBox(height: 12),
        StockBestsellerCard(name: _controller.bestSellerName),
      ],
    );
  }
}
