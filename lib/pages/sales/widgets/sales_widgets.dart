import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/sales/sales_controller.dart';

/// Linha com a caixa de busca por cliente (ícone de lupa à esquerda) e um
/// botão quadrado de filtro ao lado, igual ao print.
class salesSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  const salesSearchBar({super.key, required this.onChanged, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Buscar cliente...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            // TODO: implementar filtros reais (por status, período, etc).
            onTap: onFilterTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.tune, color: AppColors.headerStart),
            ),
          ),
        ),
      ],
    );
  }
}

/// Selo de status da venda ("Entregue" / "Pago" / "Pendente").
class salestatusBadge extends StatelessWidget {
  final salestatus status;

  const salestatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case salestatus.entregue:
        bg = const Color(0xFFF3E3DF);
        fg = AppColors.headerStart;
        label = 'Entregue';
        break;
      case salestatus.pago:
        bg = const Color(0xFFDFF3E1);
        fg = AppColors.success;
        label = 'Pago';
        break;
      case salestatus.pendente:
        bg = const Color(0xFFFBE7CC);
        fg = AppColors.goldDark;
        label = 'Pendente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Card de uma venda: data, selo de status, nome do cliente, itens do
/// pedido (buscados via pedido_id em itens_pedido), valor total e botão
/// "Emitir Nota Fiscal".
class VendaListTile extends StatelessWidget {
  final Pedido pedido;
  final String nomeCliente;
  final List<ItemPedido> itens;
  final VoidCallback onTap;
  final VoidCallback onEmitirNotaFiscal;

  const VendaListTile({
    super.key,
    required this.pedido,
    required this.nomeCliente,
    required this.itens,
    required this.onTap,
    required this.onEmitirNotaFiscal,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatarDataPedido(pedido.data),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  salestatusBadge(status: pedido.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                nomeCliente,
                style: const TextStyle(
                  color: AppColors.headerStart,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in itens)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${item.quantidade}x ${item.produtoNome}',
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          formatarValorReais(pedido.valorTotal),
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    // Botão só clicável por enquanto — a lógica real de
                    // emissão fica marcada como TODO no controller
                    // (salesController.emitirNotaFiscal).
                    onPressed: onEmitirNotaFiscal,
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text(
                      'Emitir Nota\nFiscal',
                      textAlign: TextAlign.center,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formata uma data como no print: "12 DE OUTUBRO, 2023".
/// TODO: se o app passar a usar `intl`, trocar por DateFormat pt_BR.
String formatarDataPedido(DateTime data) {
  const meses = [
    'JANEIRO',
    'FEVEREIRO',
    'MARÇO',
    'ABRIL',
    'MAIO',
    'JUNHO',
    'JULHO',
    'AGOSTO',
    'SETEMBRO',
    'OUTUBRO',
    'NOVEMBRO',
    'DEZEMBRO',
  ];
  final dia = data.day.toString().padLeft(2, '0');
  final mes = meses[data.month - 1];
  return '$dia DE $mes, ${data.year}';
}

/// Formata um valor em reais: "R\$ 148,00".
String formatarValorReais(double valor) {
  final fixo = valor.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $fixo';
}
