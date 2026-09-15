import 'package:flutter/material.dart';
import 'package:sistema_polpas/rust/clientes.dart' as rust;

enum ClienteStatus { ativo, pendente }

class EnderecoLocal {
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String municipio;
  final String uf;

  const EnderecoLocal({
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.municipio,
    required this.uf,
  });

  EnderecoLocal copyWith({
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? municipio,
    String? uf,
  }) {
    return EnderecoLocal(
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      municipio: municipio ?? this.municipio,
      uf: uf ?? this.uf,
    );
  }
}

class ClienteLocal {
  final int id;
  final String nome;
  final String cadastro;
  final String telefone;
  final EnderecoLocal endereco;
  final ClienteStatus status;

  const ClienteLocal({
    required this.id,
    required this.nome,
    required this.cadastro,
    required this.telefone,
    required this.endereco,
    this.status = ClienteStatus.ativo,
  });

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  ClienteLocal copyWith({
    String? nome,
    String? cadastro,
    String? telefone,
    EnderecoLocal? endereco,
    ClienteStatus? status,
  }) {
    return ClienteLocal(
      id: id,
      nome: nome ?? this.nome,
      cadastro: cadastro ?? this.cadastro,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      status: status ?? this.status,
    );
  }
}

ClienteLocal _fromRust(rust.Cliente c) {
  return ClienteLocal(
    id: c.id.toInt(),
    nome: c.nome,
    cadastro: c.cadastro,
    telefone: c.telefone,
    endereco: EnderecoLocal(
      cep: c.endereco.cep,
      logradouro: c.endereco.logradouro,
      numero: c.endereco.numero,
      complemento: c.endereco.complemento,
      bairro: c.endereco.bairro,
      municipio: c.endereco.municipio,
      uf: c.endereco.uf,
    ),
  );
}

rust.Cliente _toRust(ClienteLocal c) {
  return rust.Cliente(
    id: c.id,
    nome: c.nome,
    cadastro: c.cadastro,
    telefone: c.telefone,
    endereco: rust.Endereco(
      cep: c.endereco.cep,
      logradouro: c.endereco.logradouro,
      numero: c.endereco.numero,
      complemento: c.endereco.complemento,
      bairro: c.endereco.bairro,
      municipio: c.endereco.municipio,
      uf: c.endereco.uf,
    ),
  );
}

class ClientesController extends ChangeNotifier {
  List<ClienteLocal> _clientes = [];
  bool _carregando = false;
  String _erro = '';

  bool get carregando => _carregando;
  String get erro => _erro;

  String _busca = '';
  String get busca => _busca;

  int get totalAtivos =>
      _clientes.where((c) => c.status == ClienteStatus.ativo).length;
  final int novosEstaSemana = 0;

  List<ClienteLocal> get clientes {
    if (_busca.trim().isEmpty) return List.unmodifiable(_clientes);
    final termo = _busca.trim().toLowerCase();
    return _clientes
        .where((c) => c.nome.toLowerCase().contains(termo))
        .toList(growable: false);
  }

  void atualizarBusca(String termo) {
    _busca = termo;
    notifyListeners();
  }

  Future<void> carregarClientes() async {
    _carregando = true;
    _erro = '';
    notifyListeners();

    try {
      final clientesRust = await rust.listarClientes();
      _clientes = clientesRust.map(_fromRust).toList();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> adicionarCliente(ClienteLocal cliente) async {
    try {
      await rust.incluirCliente(cliente: _toRust(cliente));
      await carregarClientes();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> atualizarCliente(ClienteLocal cliente) async {
    try {
      await rust.atualizarCliente(
        cliente: _toRust(cliente),
        clienteId: cliente.id,
      );
      await carregarClientes();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> excluirCliente(ClienteLocal cliente) async {
    try {
      await rust.excluirCliente(
        cliente: _toRust(cliente),
        clienteId: cliente.id,
      );
      await carregarClientes();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }
}
