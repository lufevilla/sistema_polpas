import 'package:flutter/foundation.dart';
import '../../core/models/produto_estoque.dart';
import '../../core/utils/rust_error.dart';
import '../../src/rust/api/estoque_service.dart' as svc;
import '../../src/rust/models/pedido.dart';

export '../../src/rust/models/pedido.dart' show Produto;

class StockController extends ChangeNotifier {
  final List<Produto> _items = [];
  bool _carregando = false;
  String _erro = '';

  List<Produto> get items => List.unmodifiable(_items);
  bool get carregando => _carregando;
  String get erro => _erro;
  int get totalStock =>
      _items.fold(0, (sum, item) => sum + item.quantidadeEst.toInt());
  int get lowStockCount => _items.where((item) => item.isLow).length;
  String get bestSellerName => _items.isNotEmpty ? _items.first.nomeMerc : '—';

  Future<void> carregarEstoque() async {
    _carregando = true;
    _erro = '';
    notifyListeners();
    try {
      final produtos = await svc.listagemDoEstoque();
      _items
        ..clear()
        ..addAll(produtos);
    } catch (e) {
      _erro = extrairMensagemErro(e);
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> incluirItem(Produto produto) async {
    try {
      await svc.incluirItemEstoque(produto: produto);
      await carregarEstoque();
    } catch (e) {
      _erro = extrairMensagemErro(e);
      notifyListeners();
    }
  }

  Future<void> registrarEntrada({
    required Produto produto,
    required int quantidade,
    required double valorUnitario,
  }) async {
    try {
      await svc.entradaNoEstoque(
        idMerc: produto.idMerc,
        quantidadeAAdicionar: quantidade,
        valorUnitarioCompra: valorUnitario,
      );
      await carregarEstoque();
    } catch (e) {
      _erro = extrairMensagemErro(e);
      notifyListeners();
    }
  }

  Future<void> decrement(Produto produto) async {
    try {
      await svc.saidaEstoque(
        idMerc: produto.idMerc,
        quantidadeSaida: 1,
      );
      await carregarEstoque();
    } catch (e) {
      _erro = extrairMensagemErro(e);
      notifyListeners();
    }
  }

  Future<void> excluirItem(Produto produto) async {
    try {
      await svc.excluirItem(idMerc: produto.idMerc);
      await carregarEstoque();
    } catch (e) {
      _erro = extrairMensagemErro(e);
      notifyListeners();
    }
  }
}
