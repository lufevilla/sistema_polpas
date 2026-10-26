import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/src/rust/models/pedido.dart';

Future<void> mostrarModalEntradaEstoque({
  required BuildContext context,
  required Produto produto,
  required void Function(int quantidade, double valorUnitario) aoSalvar,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EntradaEstoqueModal(
      produto: produto,
      aoSalvar: aoSalvar,
    ),
  );
}

class _EntradaEstoqueModal extends StatefulWidget {
  final Produto produto;
  final void Function(int quantidade, double valorUnitario) aoSalvar;

  const _EntradaEstoqueModal({
    required this.produto,
    required this.aoSalvar,
  });

  @override
  State<_EntradaEstoqueModal> createState() => _EntradaEstoqueModalState();
}

class _EntradaEstoqueModalState extends State<_EntradaEstoqueModal> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _valorUnitarioController = TextEditingController();

  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorUnitarioController.dispose();
    super.dispose();
  }

  void _aoSalvar() {
    if (!_formKey.currentState!.validate()) return;

    final quantidade = int.parse(_quantidadeController.text.trim());
    final valorUnitario = double.parse(
      _valorUnitarioController.text.trim().replaceAll(',', '.'),
    );

    widget.aoSalvar(quantidade, valorUnitario);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text(
                    'Entrada no estoque',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.produto.nomeMerc,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _campo(
                    controlador: _quantidadeController,
                    label: 'Quantidade',
                    tipoTeclado: TextInputType.number,
                    validador: (value) {
                      final quantidade = int.tryParse(value?.trim() ?? '');
                      if (quantidade == null || quantidade <= 0) {
                        return 'Quantidade inválida';
                      }
                      return null;
                    },
                  ),
                  _campo(
                    controlador: _valorUnitarioController,
                    label: 'Valor unitário da compra (R\$)',
                    tipoTeclado: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    acaoTeclado: TextInputAction.done,
                    validador: (value) {
                      final valor = double.tryParse(
                        (value ?? '').trim().replaceAll(',', '.'),
                      );
                      if (valor == null || valor <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _aoSalvar,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Registrar entrada',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _campo({
    required TextEditingController controlador,
    required String label,
    TextInputType tipoTeclado = TextInputType.text,
    TextInputAction acaoTeclado = TextInputAction.next,
    required String? Function(String?) validador,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controlador,
        keyboardType: tipoTeclado,
        textInputAction: acaoTeclado,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        validator: validador,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: AppColors.cardBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
        ),
      ),
    );
  }
}
