import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/clients/clients_controller.dart';

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
          hintText: 'Pesquisar clientes...',
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

class ClienteStatusBadge extends StatelessWidget {
  final ClienteStatus status;

  const ClienteStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final ehAtivo = status == ClienteStatus.ativo;
    final fundo = ehAtivo ? const Color(0xFFDFF3E1) : const Color(0xFFFBE7CC);
    final frente = ehAtivo ? AppColors.success : AppColors.goldDark;
    final rotulo = ehAtivo ? 'Ativo' : 'Pendente';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rotulo,
        style: TextStyle(color: frente, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class ClienteListTile extends StatelessWidget {
  final ClienteLocal cliente;
  final VoidCallback aoTocar;

  const ClienteListTile({
    super.key,
    required this.cliente,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: aoTocar,
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

class BotaoAdicionarCliente extends StatelessWidget {
  final VoidCallback aoTocar;

  const BotaoAdicionarCliente({super.key, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: aoTocar,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.add, color: AppColors.textDark, size: 28),
        ),
      ),
    );
  }
}
