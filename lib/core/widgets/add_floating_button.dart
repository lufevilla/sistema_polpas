import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';

/// Botão flutuante circular "+" reutilizável (dourado, no mesmo tom usado
/// em todo o app) para abrir modais de criação — novo cliente, nova
/// venda, etc. Antes vivia só dentro da aba Clientes; agora é um widget
/// de uso geral em core/widgets, pra ser reaproveitado por qualquer
/// feature.
class AddFloatingButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const AddFloatingButton({
    super.key,
    required this.onTap,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: AppColors.textDark, size: 28),
        ),
      ),
    );
  }
}
