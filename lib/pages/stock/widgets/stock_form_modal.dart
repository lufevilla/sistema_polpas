import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/stock/models/stock_item.dart';

Future<void> mostrarModalNovoItemEstoque({
  required BuildContext context,
  required void Function(StockItem item) aoSalvar,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StockFormModal(aoSalvar: aoSalvar),
  );
}

class _StockFormModal extends StatefulWidget {
  final void Function(StockItem item) aoSalvar;

  const _StockFormModal({required this.aoSalvar});

  @override
  State<_StockFormModal> createState() => _StockFormModalState();
}

class _StockFormModalState extends State<_StockFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _embalagemController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _valorUnitarioController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _embalagemController.dispose();
    _quantidadeController.dispose();
    _valorUnitarioController.dispose();
    super.dispose();
  }

  void _aoSalvar() {
    if (!_formKey.currentState!.validate()) return;

    final item = StockItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nomeController.text.trim(),
      packageLabel: _embalagemController.text.trim(),
      quantity: int.tryParse(_quantidadeController.text.trim()) ?? 0,
      capacity: int.tryParse(_quantidadeController.text.trim()) ?? 0
    );

    widget.aoSalvar(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                    'Novo item de estoque',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _campo(
                    controlador: _nomeController,
                    label: 'Nome do produto',
                    acaoTeclado: TextInputAction.next,
                  ),
                  _campo(
                    controlador: _embalagemController,
                    label: 'Embalagem (ex: Pacote 1kg)',
                    acaoTeclado: TextInputAction.next,
                  ),
                  _campo(
                    controlador: _quantidadeController,
                    label: 'Quantidade mínima',
                    tipoTeclado: TextInputType.number,
                    acaoTeclado: TextInputAction.next,
                  ),
                  _campo(
                    controlador: _valorUnitarioController,
                    label: 'Valor unitário (R\$)',
                    tipoTeclado: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    acaoTeclado: TextInputAction.done,
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
                        'Adicionar item',
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controlador,
        keyboardType: tipoTeclado,
        textInputAction: acaoTeclado,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
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
