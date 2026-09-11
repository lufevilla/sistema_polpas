import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';

// O cabeçalho (antigo HomeHeader) virou um componente fixo do app inteiro
// e foi movido para lib/features/appHeader/app_header.dart

/// Card grande e amarelo de destaque para "Novo Pedido".
class NovoPedidoCard extends StatelessWidget {
  final VoidCallback onTap;

  const NovoPedidoCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Novo Pedido',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Registrar venda rápida',
                      style: TextStyle(color: AppColors.textDark, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: AppColors.textDark,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card menor usado para "Clientes" e "sales" (ação rápida com ícone + label).
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3ECE3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.headerStart, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha/tile de "Notas Fiscais" com ícone, título, subtítulo e seta.
class NotasFiscaisTile extends StatelessWidget {
  final VoidCallback onTap;

  const NotasFiscaisTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3ECE3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.headerStart,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas Fiscais',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    // TODO: link real para o módulo de documentos fiscais.
                    Text(
                      'Gerenciar documentos',
                      style: TextStyle(color: AppColors.goldDark, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seção "Destaques do Estoque": título + ícone + lista de itens + link
/// "Ver stock completo" no rodapé da seção.
class StockHighlightSection extends StatelessWidget {
  final List<StockItem> items;
  final VoidCallback onVerEstoqueCompleto;

  const StockHighlightSection({
    super.key,
    required this.items,
    required this.onVerEstoqueCompleto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Text(
                'Destaques do Estoque',
                style: TextStyle(
                  color: AppColors.headerStart,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              // TODO: ação para abrir filtros/categorias de estoque.
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in items) ...[
            StockItemTile(item: item),
            const SizedBox(height: 14),
          ],
          const Divider(height: 24, color: AppColors.border),
          Center(
            child: TextButton(
              onPressed: onVerEstoqueCompleto,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver estoque completo',
                    style: TextStyle(
                      color: AppColors.headerStart,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.headerStart,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha de um item de stock: imagem (placeholder), nome, barra de
/// progresso e quantidade/etiqueta de "Baixo!".
class StockItemTile extends StatelessWidget {
  final StockItem item;

  const StockItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TODO: substituir por Image.asset/Image.network real do produto.
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.placeholderColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEFE6D8),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    item.isLow ? AppColors.danger : AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          item.quantityLabel,
          style: TextStyle(
            color: item.isLow ? AppColors.danger : AppColors.textMuted,
            fontWeight: item.isLow ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
