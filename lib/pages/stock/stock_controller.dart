import 'package:flutter/foundation.dart';

import 'package:sistema_polpas/rust/estoque.dart' as rust;
import 'models/stock_item.dart';

class StockController extends ChangeNotifier {
  final List<StockItem> _items = [];
  bool _carregando = false;
  String _erro = '';

  List<StockItem> get items => List.unmodifiable(_items);
  bool get carregando => _carregando;
  String get erro => _erro;
  int get totalStock => _items.fold(0, (sum, item) => sum + item.quantity);
  int get lowStockCount => _items
      .where(
        (item) =>
            item.status == StockStatus.low ||
            item.status == StockStatus.critical,
      )
      .length;
  String get bestSellerName => _items.isNotEmpty ? _items.first.name : '—';

  Future<void> carregarEstoque() async {
    _carregando = true;
    _erro = '';
    notifyListeners();
    try {
      final produtos = await rust.carregarEstoque();
      _items
        ..clear()
        ..addAll(produtos.map(StockItem.fromProduto));
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> incluirItem({
    required String nome,
    required int quantidade,
    required int quantidadeMinima,
    required double valorUnitario,
  }) async {
    try {
      await rust.incluirItemEstoque(
        produto: rust.Produto(
          idMerc: 0,
          nomeMerc: nome,
          quantidadeEst: quantidade,
          quantidadeMinima: quantidadeMinima,
          valorUnitario: valorUnitario,
        ),
      );
      await carregarEstoque();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> increment(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    try {
      await rust.entradaEstoque(
        idMerc: int.parse(id),
        quantidadeAAdicionar: 1,
      );
      await carregarEstoque();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> decrement(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    try {
      await rust.saidaEstoque(
        idMerc: int.parse(id),
        quantidadeSaida: 1,
      );
      await carregarEstoque();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> excluirItem(String id) async {
    try {
      await rust.excluirItemEstoque(idMerc: int.parse(id));
      await carregarEstoque();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> startNewBatch(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    try {
      final item = _items[index];
      final toAdd = item.capacity - item.quantity;
      if (toAdd <= 0) return;
      await rust.entradaEstoque(
        idMerc: int.parse(id),
        quantidadeAAdicionar: toAdd,
      );
      await carregarEstoque();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }
}
