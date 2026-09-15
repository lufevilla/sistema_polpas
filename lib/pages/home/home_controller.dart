import 'package:flutter/material.dart';
import 'package:sistema_polpas/pages/clients/clients_page.dart';
import 'package:sistema_polpas/pages/sales/sales_page.dart';

/// TODO: Substituir por dados reais vindos da Session/AppConfig
/// (nome e subtítulo do negócio configurados no cadastro do dono).
class StoreInfo {
  final String name;
  final String subtitle;

  const StoreInfo({required this.name, required this.subtitle});
}

/// TODO: Substituir por model real de stock (SQLite offline-first + Supabase).
class StockItem {
  final String name;
  final String quantityLabel;
  final double progress; // 0.0 a 1.0
  final bool isLow;
  final Color placeholderColor;

  const StockItem({
    required this.name,
    required this.quantityLabel,
    required this.progress,
    required this.placeholderColor,
    this.isLow = false,
  });
}

/// Controller simples responsável por expor os dados (mockados) da Home
/// e os callbacks de navegação/ações. Sem lógica de negócio real ainda.
class HomeController extends ChangeNotifier {
  // TODO: buscar da Session (dono/funcionário) via AuthGate.
  final StoreInfo storeInfo = const StoreInfo(
    name: 'Graça e Paz',
    subtitle: 'Polpas de Fruta Artesanais',
  );

  // TODO: buscar do cache local (SQLite) primeiro, sincronizar com Supabase depois.
  // Ordenar por menor quantidade / itens em alerta primeiro.
  final List<StockItem> highlightedStock = const [
    StockItem(
      name: 'Maracujá 1kg',
      quantityLabel: '85 u.',
      progress: 0.85,
      placeholderColor: Color(0xFFE8A33D),
    ),
    StockItem(
      name: 'Acerola 500g',
      quantityLabel: 'Baixo!',
      progress: 0.12,
      isLow: true,
      placeholderColor: Color(0xFF8B1E1E),
    ),
  ];

  // TODO: navegar para tela de novo pedido / registrar venda rápida.
  void onNovoPedidoTap() {}

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
  void onNotasFiscaisTap() {}

  // TODO: navegar para tela de stock completo.
  void onVerEstoqueCompletoTap() {}
}
