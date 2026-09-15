import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/sales/sales_controller.dart';

/// Abre o modal de criação de uma nova venda (pedido + itens).
/// TODO: por enquanto o cliente é escolhido de uma lista mockada
/// (salesController.clientesDisponiveis) — no futuro deve vir da
/// tabela `clients` real, com opção de cadastrar um novo ali mesmo.
Future<void> showAddVendaModal({
  required BuildContext context,
  required List<ClienteResumo> clientesDisponiveis,
  required void Function(Pedido pedido, List<ItemPedido> itens) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VendaFormModal(
      clientesDisponiveis: clientesDisponiveis,
      onSave: onSave,
    ),
  );
}

/// Abre o modal de detalhes de uma venda existente, com opção de editar
/// ou excluir — mesmo padrão do modal de cliente.
Future<void> showVendaDetailsModal({
  required BuildContext context,
  required Pedido pedido,
  required List<ItemPedido> itens,
  required List<ClienteResumo> clientesDisponiveis,
  required void Function(Pedido pedido, List<ItemPedido> itens) onSave,
  required void Function(int idPedido) onDelete,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VendaFormModal(
      pedido: pedido,
      itensIniciais: itens,
      clientesDisponiveis: clientesDisponiveis,
      onSave: onSave,
      onDelete: onDelete,
    ),
  );
}

/// Rascunho editável de um item do pedido (itens_pedido), com os
/// controllers dos campos.
class _ItemDraft {
  final TextEditingController produtoNome;
  final TextEditingController quantidade;
  final TextEditingController valor;

  _ItemDraft({String? produtoNome, int? quantidade, double? valor})
    : produtoNome = TextEditingController(text: produtoNome ?? ''),
      quantidade = TextEditingController(text: quantidade?.toString() ?? ''),
      valor = TextEditingController(
        text: valor != null ? valor.toStringAsFixed(2) : '',
      );

  double get subtotal {
    final qtd = int.tryParse(quantidade.text.trim()) ?? 0;
    final val = double.tryParse(valor.text.trim().replaceAll(',', '.')) ?? 0;
    return qtd * val;
  }

  void dispose() {
    produtoNome.dispose();
    quantidade.dispose();
    valor.dispose();
  }
}

class _VendaFormModal extends StatefulWidget {
  final Pedido? pedido;
  final List<ItemPedido> itensIniciais;
  final List<ClienteResumo> clientesDisponiveis;
  final void Function(Pedido pedido, List<ItemPedido> itens) onSave;
  final void Function(int idPedido)? onDelete;

  const _VendaFormModal({
    this.pedido,
    this.itensIniciais = const [],
    required this.clientesDisponiveis,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_VendaFormModal> createState() => _VendaFormModalState();
}

class _VendaFormModalState extends State<_VendaFormModal> {
  final _formKey = GlobalKey<FormState>();

  late int? _clienteId = widget.pedido?.clienteId;
  late DateTime _data = widget.pedido?.data ?? DateTime.now();
  late SaleStatus _status = widget.pedido?.status ?? SaleStatus.pendente;

  late final List<_ItemDraft> _itens = widget.itensIniciais.isNotEmpty
      ? widget.itensIniciais
            .map(
              (i) => _ItemDraft(
                produtoNome: i.produtoNome,
                quantidade: i.quantidade,
                valor: i.valor,
              ),
            )
            .toList()
      : [_ItemDraft()];

  bool get _isEditingExisting => widget.pedido != null;
  late bool _isEditable = !_isEditingExisting;

  double get _valorTotal =>
      _itens.fold(0, (soma, item) => soma + item.subtotal);

  @override
  void dispose() {
    for (final item in _itens) {
      item.dispose();
    }
    super.dispose();
  }

  void _adicionarItem() {
    setState(() => _itens.add(_ItemDraft()));
  }

  void _removerItem(int index) {
    setState(() {
      _itens[index].dispose();
      _itens.removeAt(index);
    });
  }

  Future<void> _selecionarData() async {
    final novaData = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (novaData != null) setState(() => _data = novaData);
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteId == null) return;
    if (_itens.isEmpty) return;

    final pedido = Pedido(
      idPedido: widget.pedido?.idPedido ?? 0,
      clienteId: _clienteId!,
      data: _data,
      valorTotal: _valorTotal,
      status: _status,
    );

    final itens = _itens
        .map(
          (item) => ItemPedido(
            idItem: 0,
            pedidoId: pedido.idPedido,
            produtoNome: item.produtoNome.text.trim(),
            quantidade: int.tryParse(item.quantidade.text.trim()) ?? 0,
            valor:
                double.tryParse(item.valor.text.trim().replaceAll(',', '.')) ??
                0,
            subtotal: item.subtotal,
          ),
        )
        .toList();

    widget.onSave(pedido, itens);
    Navigator.of(context).pop();
  }

  Future<void> _handleExcluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir venda'),
        content: const Text(
          'Tem certeza que deseja excluir esse pedido? Todos os itens '
          'ligados a ele também serão removidos. Essa ação não pode ser '
          'desfeita.',
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
      widget.onDelete?.call(widget.pedido!.idPedido);
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
                    _isEditingExisting ? 'Detalhes da venda' : 'Nova venda',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _clienteField(),
                  const SizedBox(height: 14),
                  _dataField(),
                  const SizedBox(height: 14),
                  _statusField(),
                  const SizedBox(height: 20),
                  const Text(
                    'Itens do pedido',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _itens.length; i++) ...[
                    _itemCard(i),
                    const SizedBox(height: 12),
                  ],
                  if (_isEditable)
                    TextButton.icon(
                      onPressed: _adicionarItem,
                      icon: const Icon(Icons.add, color: AppColors.headerStart),
                      label: const Text(
                        'Adicionar item',
                        style: TextStyle(color: AppColors.headerStart),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valor total',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'R\$ ${_valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _actions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _clienteField() {
    return DropdownButtonFormField<int>(
      initialValue: _clienteId,
      items: widget.clientesDisponiveis
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
          .toList(),
      onChanged: _isEditable
          ? (value) => setState(() => _clienteId = value)
          : null,
      validator: (value) => value == null ? 'Selecione um cliente' : null,
      decoration: _decoration('Cliente'),
    );
  }

  Widget _dataField() {
    final texto =
        '${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}';
    return TextFormField(
      readOnly: true,
      enabled: _isEditable,
      onTap: _isEditable ? _selecionarData : null,
      controller: TextEditingController(text: texto),
      decoration: _decoration('Data').copyWith(
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
      ),
    );
  }

  Widget _statusField() {
    return DropdownButtonFormField<SaleStatus>(
      initialValue: _status,
      items: const [
        DropdownMenuItem(value: SaleStatus.pendente, child: Text('Pendente')),
        DropdownMenuItem(value: SaleStatus.pago, child: Text('Pago')),
        DropdownMenuItem(value: SaleStatus.entregue, child: Text('Entregue')),
      ],
      onChanged: _isEditable
          ? (value) => setState(() => _status = value!)
          : null,
      decoration: _decoration('Status'),
    );
  }

  Widget _itemCard(int index) {
    final item = _itens[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.produtoNome,
                  enabled: _isEditable,
                  style: const TextStyle(fontSize: 14),
                  decoration: _decoration('Produto', dense: true),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Obrigatório'
                      : null,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_isEditable && _itens.length > 1)
                IconButton(
                  onPressed: () => _removerItem(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.danger,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.quantidade,
                  enabled: _isEditable,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                  decoration: _decoration('Qtd.', dense: true),
                  validator: (value) {
                    final qtd = int.tryParse(value?.trim() ?? '');
                    return (qtd == null || qtd <= 0) ? 'Inválido' : null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: item.valor,
                  enabled: _isEditable,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                  decoration: _decoration('Valor unit.', dense: true),
                  validator: (value) {
                    final val = double.tryParse(
                      (value ?? '').trim().replaceAll(',', '.'),
                    );
                    return (val == null || val <= 0) ? 'Inválido' : null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, {bool dense = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: _isEditable
          ? AppColors.cardBackground
          : const Color(0xFFF3ECE3),
      isDense: dense,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: dense ? 10 : 14,
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
    );
  }

  Widget _actions() {
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
            'Salvar venda',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

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
