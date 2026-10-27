import 'package:flutter/material.dart';
import 'package:sistema_polpas/pages/clients/clients_page.dart';
import 'package:sistema_polpas/pages/sales/sales_page.dart';
import 'package:sistema_polpas/pages/stock/stock_page.dart';
import '../../core/models/produto_estoque.dart';
import '../../core/utils/rust_error.dart';
import '../../src/rust/api/estoque_service.dart' as svc;
import '../../src/rust/models/pedido.dart';

/// TODO: Substituir por dados reais vindos da Session/AppConfig
/// (nome e subtítulo do negócio configurados no cadastro do dono).
class StoreInfo {
  final String name;
  final String subtitle;

  const StoreInfo({required this.name, required this.subtitle});
}

/// Controller da Home: carrega os destaques do estoque do backend e expõe
/// os callbacks de navegação.
class HomeController extends ChangeNotifier {
  // TODO: buscar da Session (dono/funcionário) via AuthGate.
  final StoreInfo storeInfo = const StoreInfo(
    name: 'Graça e Paz',
    subtitle: 'Polpas de Fruta Artesanais',
  );

  final List<Produto> _highlightedStock = [];
  bool _carregando = false;
  String _erro = '';

  List<Produto> get highlightedStock => List.unmodifiable(_highlightedStock);
  bool get carregando => _carregando;
  String get erro => _erro;

  Future<void> carregarEstoque() async {
    _carregando = true;
    _erro = '';
    notifyListeners();
    try {
      final produtos = await svc.listagemDoEstoque();
      final ordenados = List<Produto>.from(produtos)
        ..sort((a, b) => a.occupancyRatio.compareTo(b.occupancyRatio));
      _highlightedStock
        ..clear()
        ..addAll(ordenados.take(2));
    } catch (e) {
      _erro = extrairMensagemErro(e);
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // TODO: navegar para tela de novo pedido / registrar venda rápida.
  void onNovoPedidoTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SalesPage()),
    );
  }

  // TODO: navegar para lista de clients.
  void onClientesTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientesPage()),
    );
  }

  // TODO: navegar para lista de sales.
  void onsalesTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SalesPage()),
    );
  }

  // TODO: navegar para módulo de notas fiscais / documentos.
  // void onNotasFiscaisTap() {}

  // TODO: navegar para tela de stock completo.
  void onVerEstoqueCompletoTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockPage()),
    );
  }
}
