import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/clients/clients_controller.dart';

/// Caixa de pesquisa retangular com borda visível e ícone de lupa na
/// extrema direita, no lugar do card "Base de Clientes" do print original.
class ClientesSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ClientesSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Pesquisar clients...',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          suffixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

/// Card branco "Base de Clientes" com o total de ativos e novos da semana,
/// no lugar do card amarelo de fidelidade Premium do print original.
class ClientesStatsCard extends StatelessWidget {
  final int totalAtivos;
  final int novosEstaSemana;

  const ClientesStatsCard({
    super.key,
    required this.totalAtivos,
    required this.novosEstaSemana,
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
          const Text(
            'BASE DE CLIENTES',
            style: TextStyle(
              color: AppColors.headerStart,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$totalAtivos Ativos',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+$novosEstaSemana novos esta semana',
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Selo de status ("Ativo" / "Pendente").
class ClienteStatusBadge extends StatelessWidget {
  final ClienteStatus status;

  const ClienteStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isAtivo = status == ClienteStatus.ativo;
    final bg = isAtivo ? const Color(0xFFDFF3E1) : const Color(0xFFFBE7CC);
    final fg = isAtivo ? AppColors.success : AppColors.goldDark;
    final label = isAtivo ? 'Ativo' : 'Pendente';

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

/// Linha de cliente na listagem: avatar com iniciais, nome, telefone,
/// selo de status e seta indicando que é clicável.
class ClienteListTile extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap;

  const ClienteListTile({
    super.key,
    required this.cliente,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF3ECE3),
                child: Text(
                  cliente.iniciais,
                  style: const TextStyle(
                    color: AppColors.headerStart,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nome,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cliente.telefone,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ClienteStatusBadge(status: cliente.status),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão flutuante "+" (mesmo tom de dourado usado no resto do app) para
/// abrir o modal de cadastro de novo cliente.
class AddClienteButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddClienteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.add, color: AppColors.textDark, size: 28),
        ),
      ),
    );
  }
}
