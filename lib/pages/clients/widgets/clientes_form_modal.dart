import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/clients/clients_controller.dart';

/// Abre o modal de cadastro de um novo cliente.
Future<void> showAddClienteModal({
  required BuildContext context,
  required void Function(Cliente cliente) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ClienteFormModal(onSave: onSave),
  );
}

/// Abre o modal de detalhes de um cliente já existente (com opção de
/// editar ou excluir).
Future<void> showClienteDetailsModal({
  required BuildContext context,
  required Cliente cliente,
  required void Function(Cliente cliente) onSave,
  required void Function(String id) onDelete,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _ClienteFormModal(cliente: cliente, onSave: onSave, onDelete: onDelete),
  );
}

/// Modal único (form) usado tanto para criar quanto para visualizar/editar
/// um cliente, seguindo exatamente as colunas da tabela `clients`.
class _ClienteFormModal extends StatefulWidget {
  final Cliente? cliente;
  final void Function(Cliente cliente) onSave;
  final void Function(String id)? onDelete;

  const _ClienteFormModal({this.cliente, required this.onSave, this.onDelete});

  @override
  State<_ClienteFormModal> createState() => _ClienteFormModalState();
}

class _ClienteFormModalState extends State<_ClienteFormModal> {
  final _formKey = GlobalKey<FormState>();

  late final _nome = TextEditingController(text: widget.cliente?.nome);
  late final _cadastro = TextEditingController(text: widget.cliente?.cadastro);
  late final _telefone = TextEditingController(text: widget.cliente?.telefone);
  late final _cep = TextEditingController(text: widget.cliente?.endereco.cep);
  late final _logradouro = TextEditingController(
    text: widget.cliente?.endereco.logradouro,
  );
  late final _numero = TextEditingController(
    text: widget.cliente?.endereco.numero,
  );
  late final _complemento = TextEditingController(
    text: widget.cliente?.endereco.complemento,
  );
  late final _bairro = TextEditingController(
    text: widget.cliente?.endereco.bairro,
  );
  late final _municipio = TextEditingController(
    text: widget.cliente?.endereco.municipio,
  );
  late final _uf = TextEditingController(text: widget.cliente?.endereco.uf);

  bool get _isEditingExisting => widget.cliente != null;
  // Cadastro novo já começa em modo de edição; cadastro existente começa
  // travado, só libera os campos depois de tocar em "Editar".
  late bool _isEditable = !_isEditingExisting;

  @override
  void dispose() {
    _nome.dispose();
    _cadastro.dispose();
    _telefone.dispose();
    _cep.dispose();
    _logradouro.dispose();
    _numero.dispose();
    _complemento.dispose();
    _bairro.dispose();
    _municipio.dispose();
    _uf.dispose();
    super.dispose();
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;

    final cliente = Cliente(
      id:
          widget.cliente?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nome.text.trim(),
      cadastro: _cadastro.text.trim(),
      telefone: _telefone.text.trim(),
      endereco: Endereco(
        cep: _cep.text.trim(),
        logradouro: _logradouro.text.trim(),
        numero: _numero.text.trim(),
        complemento: _complemento.text.trim().isEmpty
            ? null
            : _complemento.text.trim(),
        bairro: _bairro.text.trim(),
        municipio: _municipio.text.trim(),
        uf: _uf.text.trim(),
      ),
      status: widget.cliente?.status ?? ClienteStatus.pendente,
    );

    widget.onSave(cliente);
    Navigator.of(context).pop();
  }

  Future<void> _handleExcluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: Text(
          'Tem certeza que deseja excluir "${widget.cliente!.nome}"? '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      widget.onDelete?.call(widget.cliente!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
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
                  Text(
                    _isEditingExisting ? 'Dados do cliente' : 'Novo cliente',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(controller: _nome, label: 'Nome completo'),
                  _field(controller: _cadastro, label: 'Cadastro (CPF/CNPJ)'),
                  _field(
                    controller: _telefone,
                    label: 'Telefone',
                    keyboardType: TextInputType.phone,
                  ),
                  _field(
                    controller: _cep,
                    label: 'CEP',
                    keyboardType: TextInputType.number,
                  ),
                  _field(controller: _logradouro, label: 'Logradouro'),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _field(
                          controller: _numero,
                          label: 'Número',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _field(
                          controller: _complemento,
                          label: 'Complemento (opcional)',
                          required: false,
                        ),
                      ),
                    ],
                  ),
                  _field(controller: _bairro, label: 'Bairro'),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _field(
                          controller: _municipio,
                          label: 'Município',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _field(controller: _uf, label: 'UF'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _actions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: _isEditable,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        validator: (value) {
          if (!required) return null;
          if (value == null || value.trim().isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: _isEditable
              ? AppColors.cardBackground
              : const Color(0xFFF3ECE3),
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

  Widget _actions() {
    // Cadastro novo: só o botão de salvar.
    if (!_isEditingExisting) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _handleSalvar,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.textDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Salvar cliente',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    // Cliente existente, modo leitura: "Editar" e "Excluir".
    if (!_isEditable) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _handleExcluir,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Excluir'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () => setState(() => _isEditable = true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Editar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );
    }

    // Cliente existente, modo edição: "Cancelar" e "Salvar alterações".
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _isEditable = false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _handleSalvar,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Salvar alterações',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
