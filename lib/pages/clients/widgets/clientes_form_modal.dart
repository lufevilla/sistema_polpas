import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/clients/clients_controller.dart';

Future<void> mostrarModalNovoCliente({
  required BuildContext context,
  required void Function(ClienteLocal cliente) aoSalvar,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ClienteFormModal(aoSalvar: aoSalvar),
  );
}

Future<void> mostrarModalDetalhesCliente({
  required BuildContext context,
  required ClienteLocal cliente,
  required void Function(ClienteLocal cliente) aoSalvar,
  required void Function(ClienteLocal cliente) aoExcluir,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ClienteFormModal(
      cliente: cliente,
      aoSalvar: aoSalvar,
      aoExcluir: aoExcluir,
    ),
  );
}

class _ClienteFormModal extends StatefulWidget {
  final ClienteLocal? cliente;
  final void Function(ClienteLocal cliente) aoSalvar;
  final void Function(ClienteLocal cliente)? aoExcluir;

  const _ClienteFormModal({
    this.cliente,
    required this.aoSalvar,
    this.aoExcluir,
  });

  @override
  State<_ClienteFormModal> createState() => _ClienteFormModalState();
}

class _ClienteFormModalState extends State<_ClienteFormModal> {
  final _chaveFormulario = GlobalKey<FormState>();

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
    text: widget.cliente?.endereco.complemento ?? '',
  );
  late final _bairro = TextEditingController(
    text: widget.cliente?.endereco.bairro,
  );
  late final _municipio = TextEditingController(
    text: widget.cliente?.endereco.municipio,
  );
  late final _uf = TextEditingController(text: widget.cliente?.endereco.uf);

  bool get _editandoExistente => widget.cliente != null;
  late bool _ehEditavel = !_editandoExistente;

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

  void _aoSalvar() {
    if (!_chaveFormulario.currentState!.validate()) return;

    final cliente = ClienteLocal(
      id: widget.cliente?.id ?? 0,
      nome: _nome.text.trim(),
      cadastro: _cadastro.text.trim(),
      telefone: _telefone.text.trim(),
      endereco: EnderecoLocal(
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

    widget.aoSalvar(cliente);
    Navigator.of(context).pop();
  }

  Future<void> _aoExcluir() async {
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
      widget.aoExcluir?.call(widget.cliente!);
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
              key: _chaveFormulario,
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
                    _editandoExistente ? 'Dados do cliente' : 'Novo cliente',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _campo(controlador: _nome, label: 'Nome completo'),
                  _campo(controlador: _cadastro, label: 'Cadastro (CPF/CNPJ)'),
                  _campo(
                    controlador: _telefone,
                    label: 'Telefone',
                    tipoTeclado: TextInputType.phone,
                  ),
                  _campo(
                    controlador: _cep,
                    label: 'CEP',
                    tipoTeclado: TextInputType.number,
                  ),
                  _campo(controlador: _logradouro, label: 'Logradouro'),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _campo(
                          controlador: _numero,
                          label: 'Número',
                          tipoTeclado: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _campo(
                          controlador: _complemento,
                          label: 'Complemento (opcional)',
                          obrigatorio: false,
                        ),
                      ),
                    ],
                  ),
                  _campo(controlador: _bairro, label: 'Bairro'),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _campo(
                          controlador: _municipio,
                          label: 'Município',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _campo(
                          controlador: _uf,
                          label: 'UF',
                          acaoTeclado: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _acoes(),
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
    bool obrigatorio = true,
    TextInputAction acaoTeclado = TextInputAction.next,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controlador,
        enabled: _ehEditavel,
        keyboardType: tipoTeclado,
        textInputAction: acaoTeclado,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        validator: (value) {
          if (!obrigatorio) return null;
          if (value == null || value.trim().isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: _ehEditavel
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

  Widget _acoes() {
    if (!_editandoExistente) {
      return SizedBox(
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
            'Salvar cliente',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    if (!_ehEditavel) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _aoExcluir,
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
              onPressed: () => setState(() => _ehEditavel = true),
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

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _ehEditavel = false),
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
            onPressed: _aoSalvar,
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
