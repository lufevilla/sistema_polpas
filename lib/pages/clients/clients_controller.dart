import 'package:flutter/material.dart';

/// Status do cliente.
/// TODO: esse campo NÃO faz parte do schema (`clients`) informado.
/// Está aqui só para reproduzir o selo "Ativo"/"Pendente" do print — a
/// regra real (ex: baseada em histórico de compras/pagamentos) deve
/// substituir isso depois.
enum ClienteStatus { ativo, pendente }

/// Modelo do cliente, espelhando exatamente as colunas da tabela
/// `clients`:
/// nome, cadastro (único), telefone, cep, logradouro, numero,
/// complemento (opcional), bairro, municipio, uf.
class Cliente {
  final String id;
  final String nome;
  final String cadastro; // TEXT UNIQUE NOT NULL (ex: CPF/CNPJ)
  final String telefone;
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String municipio;
  final String uf;
  final ClienteStatus status;

  const Cliente({
    required this.id,
    required this.nome,
    required this.cadastro,
    required this.telefone,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.municipio,
    required this.uf,
    this.status = ClienteStatus.ativo,
  });

  /// Iniciais para o avatar (ex: "Maria Auxiliadora" -> "MA").
  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  Cliente copyWith({
    String? nome,
    String? cadastro,
    String? telefone,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? municipio,
    String? uf,
    ClienteStatus? status,
  }) {
    return Cliente(
      id: id,
      nome: nome ?? this.nome,
      cadastro: cadastro ?? this.cadastro,
      telefone: telefone ?? this.telefone,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      municipio: municipio ?? this.municipio,
      uf: uf ?? this.uf,
      status: status ?? this.status,
    );
  }
}

/// Controller da aba Clientes: dados mockados + busca + CRUD em memória.
/// TODO: substituir a lista em memória por SQLite (offline-first) + sync
/// com Supabase, seguindo o mesmo padrão já usado no restante do app.
class ClientesController extends ChangeNotifier {
  final List<Cliente> _clientes = [
    const Cliente(
      id: '1',
      nome: 'Maria Auxiliadora',
      cadastro: '111.222.333-44',
      telefone: '(85) 98822-4455',
      cep: '63000-000',
      logradouro: 'Rua das Acácias',
      numero: '120',
      bairro: 'Centro',
      municipio: 'Juazeiro do Norte',
      uf: 'CE',
      status: ClienteStatus.ativo,
    ),
    const Cliente(
      id: '2',
      nome: 'João Paulo Silva',
      cadastro: '222.333.444-55',
      telefone: '(85) 99744-1122',
      cep: '63010-000',
      logradouro: 'Av. Padre Cícero',
      numero: '850',
      complemento: 'Apto 302',
      bairro: 'São Miguel',
      municipio: 'Juazeiro do Norte',
      uf: 'CE',
      status: ClienteStatus.pendente,
    ),
    const Cliente(
      id: '3',
      nome: 'Ricardo Lemos',
      cadastro: '333.444.555-66',
      telefone: '(85) 98122-3344',
      cep: '63020-000',
      logradouro: 'Rua José de Alencar',
      numero: '45',
      bairro: 'Franciscanos',
      municipio: 'Juazeiro do Norte',
      uf: 'CE',
      status: ClienteStatus.ativo,
    ),
  ];

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // TODO: buscar valores reais (total de ativos e novos da semana) do banco.
  int get totalAtivos =>
      _clientes.where((c) => c.status == ClienteStatus.ativo).length;
  final int newThisWeek = 5;

  List<Cliente> get clientes {
    if (_searchQuery.trim().isEmpty) return List.unmodifiable(_clientes);
    final query = _searchQuery.trim().toLowerCase();
    return _clientes
        .where((c) => c.nome.toLowerCase().contains(query))
        .toList(growable: false);
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addCliente(Cliente cliente) {
    _clientes.insert(0, cliente);
    notifyListeners();
  }

  void updateCliente(Cliente cliente) {
    final index = _clientes.indexWhere((c) => c.id == cliente.id);
    if (index == -1) return;
    _clientes[index] = cliente;
    notifyListeners();
  }

  void deleteCliente(String id) {
    _clientes.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
