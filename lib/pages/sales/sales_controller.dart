import 'package:flutter/material.dart';

/// Status da venda/pedido.
/// TODO: esse campo NÃO faz parte do schema (`pedidos`) informado.
/// Está aqui só pra reproduzir os selos "Entregue"/"Pago"/"Pendente" do
/// print — a regra real (ex: baseada em pagamento/entrega/nota fiscal)
/// deve substituir isso depois, possivelmente como uma coluna própria
/// ou derivada de outra tabela (ex: pagamentos, entregas).
enum salestatus { entregue, pago, pendente }

/// Referência simples de cliente (id + nome), usada só pra popular o
/// seletor de cliente no formulário de venda e exibir o nome no card.
/// TODO: substituir por uma consulta real à tabela `clients`
/// (ver lib/features/clients/clients_controller.dart) assim que as
/// duas features estiverem integradas ao mesmo banco.
class ClienteResumo {
  final int id;
  final String nome;

  const ClienteResumo({required this.id, required this.nome});
}

/// Espelha a tabela `pedidos`: id_pedidos, cliente_id, data, valor_total.
class Pedido {
  final int idPedido;
  final int clienteId;
  final DateTime data;
  final double valorTotal;
  final salestatus status; // TODO: não existe no schema, ver enum acima.

  const Pedido({
    required this.idPedido,
    required this.clienteId,
    required this.data,
    required this.valorTotal,
    this.status = salestatus.pendente,
  });

  Pedido copyWith({
    int? clienteId,
    DateTime? data,
    double? valorTotal,
    salestatus? status,
  }) {
    return Pedido(
      idPedido: idPedido,
      clienteId: clienteId ?? this.clienteId,
      data: data ?? this.data,
      valorTotal: valorTotal ?? this.valorTotal,
      status: status ?? this.status,
    );
  }
}

/// Espelha a tabela `itens_pedido`: id_item, pedido_id, produto_nome,
/// quantidade, valor, subtotal. Cada pedido pode ter vários itens — por
/// isso a busca é sempre "pelos itens_pedido daquele pedido_id", igual
/// no banco (FOREIGN KEY pedido_id -> pedidos.id_pedidos).
class ItemPedido {
  final int idItem;
  final int pedidoId;
  final String produtoNome;
  final int quantidade;
  final double valor;
  final double subtotal;

  const ItemPedido({
    required this.idItem,
    required this.pedidoId,
    required this.produtoNome,
    required this.quantidade,
    required this.valor,
    required this.subtotal,
  });
}

/// Controller da aba sales: pedidos + itens_pedido mockados em memória,
/// busca por cliente e CRUD.
/// TODO: substituir por SQLite (offline-first) + sync com Supabase,
/// seguindo o mesmo padrão já usado no restante do app. Ao excluir um
/// pedido, replicar o comportamento do `ON DELETE CASCADE` do schema
/// (os itens_pedido do pedido também são removidos — já feito aqui em
/// memória por deletePedido).
class salesController extends ChangeNotifier {
  // TODO: substituir pela lista real de clients (ver ClientesController).
  final List<ClienteResumo> clientesDisponiveis = const [
    ClienteResumo(id: 1, nome: 'Maria Fernanda Castro'),
    ClienteResumo(id: 2, nome: 'João Pedro Silva'),
    ClienteResumo(id: 3, nome: 'Restaurante Sabor Natural'),
    ClienteResumo(id: 4, nome: 'Ana Beatriz Ramos'),
  ];

  final List<Pedido> _pedidos = [
    Pedido(
      idPedido: 1,
      clienteId: 1,
      data: DateTime(2023, 10, 12),
      valorTotal: 148.00,
      status: salestatus.entregue,
    ),
    Pedido(
      idPedido: 2,
      clienteId: 2,
      data: DateTime(2023, 10, 11),
      valorTotal: 280.50,
      status: salestatus.pago,
    ),
    Pedido(
      idPedido: 3,
      clienteId: 3,
      data: DateTime(2023, 10, 10),
      valorTotal: 540.00,
      status: salestatus.pendente,
    ),
    Pedido(
      idPedido: 4,
      clienteId: 4,
      data: DateTime(2023, 10, 8),
      valorTotal: 130.00,
      status: salestatus.entregue,
    ),
  ];

  final List<ItemPedido> _itensPedido = [
    const ItemPedido(
      idItem: 1,
      pedidoId: 1,
      produtoNome: 'Polpas de Acerola',
      quantidade: 12,
      valor: 12.33,
      subtotal: 148.00,
    ),
    const ItemPedido(
      idItem: 2,
      pedidoId: 2,
      produtoNome: 'Polpas Sortidas (Promo)',
      quantidade: 24,
      valor: 11.69,
      subtotal: 280.50,
    ),
    const ItemPedido(
      idItem: 3,
      pedidoId: 3,
      produtoNome: 'Polpas de Manga (Atacado)',
      quantidade: 60,
      valor: 9.00,
      subtotal: 540.00,
    ),
    const ItemPedido(
      idItem: 4,
      pedidoId: 4,
      produtoNome: 'Polpas de Morango',
      quantidade: 10,
      valor: 13.00,
      subtotal: 130.00,
    ),
  ];

  int _nextPedidoId = 5;
  int _nextItemId = 5;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Pedidos ordenados do mais recente pro mais antigo, filtrados pelo
  /// nome do cliente (busca por texto, igual ao campo "Buscar cliente...").
  List<Pedido> get pedidos {
    final ordenados = [..._pedidos]..sort((a, b) => b.data.compareTo(a.data));
    if (_searchQuery.trim().isEmpty) return ordenados;
    final query = _searchQuery.trim().toLowerCase();
    return ordenados
        .where((p) => nomeCliente(p.clienteId).toLowerCase().contains(query))
        .toList(growable: false);
  }

  /// Busca os itens_pedido de um pedido específico (join simulado pela
  /// FOREIGN KEY pedido_id).
  List<ItemPedido> itensDoPedido(int pedidoId) {
    return _itensPedido.where((i) => i.pedidoId == pedidoId).toList();
  }

  String nomeCliente(int clienteId) {
    final cliente = clientesDisponiveis.firstWhere(
      (c) => c.id == clienteId,
      orElse: () => const ClienteResumo(id: -1, nome: 'Cliente não encontrado'),
    );
    return cliente.nome;
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addPedido(Pedido pedidoDraft, List<ItemPedido> itensDraft) {
    final pedido = Pedido(
      idPedido: _nextPedidoId,
      clienteId: pedidoDraft.clienteId,
      data: pedidoDraft.data,
      valorTotal: pedidoDraft.valorTotal,
      status: pedidoDraft.status,
    );
    _pedidos.add(pedido);
    for (final item in itensDraft) {
      _itensPedido.add(
        ItemPedido(
          idItem: _nextItemId++,
          pedidoId: pedido.idPedido,
          produtoNome: item.produtoNome,
          quantidade: item.quantidade,
          valor: item.valor,
          subtotal: item.subtotal,
        ),
      );
    }
    _nextPedidoId++;
    notifyListeners();
  }

  void updatePedido(Pedido pedido, List<ItemPedido> itensAtualizados) {
    final index = _pedidos.indexWhere((p) => p.idPedido == pedido.idPedido);
    if (index == -1) return;
    _pedidos[index] = pedido;

    // Substitui os itens desse pedido (igual um DELETE + INSERT no SQLite).
    _itensPedido.removeWhere((i) => i.pedidoId == pedido.idPedido);
    for (final item in itensAtualizados) {
      _itensPedido.add(
        ItemPedido(
          idItem: _nextItemId++,
          pedidoId: pedido.idPedido,
          produtoNome: item.produtoNome,
          quantidade: item.quantidade,
          valor: item.valor,
          subtotal: item.subtotal,
        ),
      );
    }
    notifyListeners();
  }

  void deletePedido(int idPedido) {
    _pedidos.removeWhere((p) => p.idPedido == idPedido);
    // Mimetiza o ON DELETE CASCADE do schema: remove os itens_pedido
    // vinculados ao pedido excluído.
    _itensPedido.removeWhere((i) => i.pedidoId == idPedido);
    notifyListeners();
  }

  // TODO: implementar emissão de nota fiscal (integração com sistema
  // fiscal / API da prefeitura ou de um emissor terceirizado). Por
  // enquanto o botão "Emitir Nota Fiscal" não faz nada.
  void emitirNotaFiscal(int idPedido) {}
}
