# Conectar Estoque ao Backend Rust - Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Conectar a página de estoque ao backend Rust/SQLite, substituindo os dados mockados.

**Architecture:** StockController passa a chamar as funções Rust via wrapper `lib/rust/estoque.dart`. StockItem ganha factory `fromProduto()`. StockPage ganha loading/error states.

**Tech Stack:** Dart/Flutter, flutter_rust_bridge, Rust, SQLite

---

## File Structure

```
lib/rust/estoque.dart                   ← MODIFICAR: adicionar saidaEstoque()
lib/pages/stock/models/stock_item.dart  ← MODIFICAR: adicionar factory fromProduto()
lib/pages/stock/stock_controller.dart   ← MODIFICAR: substituir mock por chamadas Rust
lib/pages/stock/stock_page.dart         ← MODIFICAR: adicionar loading/error states
```

---

## Task 0: Adicionar saidaEstoque() ao wrapper Dart

**Files:**
- Modify: `lib/rust/estoque.dart`

- [ ] **Step 1: Adicionar saidaEstoque()**

Adicionar ao final de `lib/rust/estoque.dart`:
```dart
Future<void> saidaEstoque({
  required int quantidadeSaida,
  required int idMerc,
}) {
  return svc.saidaEstoque(
    quantidadeSaida: quantidadeSaida,
    idMerc: idMerc,
  );
}
```

- [ ] **Step 2: Verificar compilação**

Run: `flutter analyze`
Expected: Sem erros novos

- [ ] **Step 3: Commit**

```bash
git add lib/rust/estoque.dart
git commit -m "feat(rust): add saidaEstoque wrapper"
```

---

## Task 1: Adaptar StockItem com factory fromProduto()

**Files:**
- Modify: `lib/pages/stock/models/stock_item.dart`

- [ ] **Step 1: Adicionar import do Produto Rust**

Adicionar no topo de `stock_item.dart`:
```dart
import 'package:sistema_polpas/rust/estoque.dart' show Produto;
```

- [ ] **Step 2: Adicionar factory fromProduto()**

Adicionar dentro da classe `StockItem`:
```dart
factory StockItem.fromProduto(Produto p) {
  return StockItem(
    id: p.idMerc.toString(),
    name: p.nomeMerc,
    packageLabel: 'Pacote 1kg',
    quantity: p.quantidadeEst.toInt(),
    capacity: p.quantidadeMinima.toInt(),
  );
}
```

- [ ] **Step 3: Verificar compilação**

Run: `flutter analyze`
Expected: Sem erros novos

- [ ] **Step 4: Commit**

```bash
git add lib/pages/stock/models/stock_item.dart
git commit -m "feat(stock): add StockItem.fromProduto factory"
```

---

## Task 2: Reescrever StockController para usar backend Rust

**Files:**
- Modify: `lib/pages/stock/stock_controller.dart`

- [ ] **Step 1: Substituir imports**

Substituir o import existente:
```dart
import 'package:flutter/foundation.dart';
import 'models/stock_item.dart';
```

Por:
```dart
import 'package:flutter/foundation.dart';
import 'package:sistema_polpas/rust/estoque.dart' as rust;
import 'models/stock_item.dart';
```

- [ ] **Step 2: Adicionar estado de carregamento e erro**

Substituir o corpo da classe `StockController` por:
```dart
class StockController extends ChangeNotifier {
  List<StockItem> _items = [];
  bool _carregando = false;
  String _erro = '';

  bool get carregando => _carregando;
  String get erro => _erro;
  List<StockItem> get items => List.unmodifiable(_items);

  int get totalStock => _items.fold(0, (sum, item) => sum + item.quantity);

  int get lowStockCount => _items
      .where(
        (item) =>
            item.status == StockStatus.low ||
            item.status == StockStatus.critical,
      )
      .length;

  String get bestSellerName =>
      _items.isNotEmpty ? _items.first.name : '—';

  Future<void> carregarEstoque() async {
    _carregando = true;
    _erro = '';
    notifyListeners();

    try {
      final produtos = await rust.carregarEstoque();
      _items = produtos.map(StockItem.fromProduto).toList();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> increment(String id) async {
    final idMerc = int.tryParse(id);
    if (idMerc == null) return;

    try {
      await rust.entradaEstoque(idMerc: idMerc, quantidadeAAdicionar: 1);
      await carregarEstoque();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> decrement(String id) async {
    final idMerc = int.tryParse(id);
    if (idMerc == null) return;

    try {
      await rust.saidaEstoque(quantidadeSaida: 1, idMerc: idMerc);
      await carregarEstoque();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> startNewBatch(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _items[index];
    final idMerc = int.tryParse(id);
    if (idMerc == null) return;

    try {
      final quantidadeAdicionar = item.capacity - item.quantity;
      if (quantidadeAdicionar > 0) {
        await rust.entradaEstoque(
          idMerc: idMerc,
          quantidadeAAdicionar: quantidadeAdicionar,
        );
        await carregarEstoque();
      }
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }
}
```

- [ ] **Step 3: Verificar compilação**

Run: `flutter analyze`
Expected: Sem erros novos

- [ ] **Step 4: Commit**

```bash
git add lib/pages/stock/stock_controller.dart
git commit -m "feat(stock): connect StockController to Rust backend"
```

---

## Task 3: Adicionar loading/error states na StockPage

**Files:**
- Modify: `lib/pages/stock/stock_page.dart`

- [ ] **Step 1: Chamar carregarEstoque() no initState**

Adicionar `initState` na `_StockPageState`:
```dart
@override
void initState() {
  super.initState();
  _controller.addListener(() => setState(() {}));
  _controller.carregarEstoque();
}
```

- [ ] **Step 2: Adicionar loading e error no build**

Substituir o `AnimatedBuilder` por:
```dart
return Container(
  color: AppColors.background,
  child: AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      if (_controller.carregando) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.erro.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Erro ao carregar estoque',
                  style: TextStyle(color: AppColors.danger),
                ),
                const SizedBox(height: 8),
                Text(
                  _controller.erro,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _controller.carregarEstoque,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        );
      }

      return CustomScrollView(
        // ... resto do build existente
      );
    },
  ),
);
```

- [ ] **Step 3: Verificar compilação**

Run: `flutter analyze`
Expected: Sem erros novos

- [ ] **Step 4: Commit**

```bash
git add lib/pages/stock/stock_page.dart
git commit -m "feat(stock): add loading/error states to StockPage"
```

---

## Task 4: Verificação final

- [ ] **Step 1: Rodar flutter analyze**

Run: `flutter analyze`
Expected: Sem erros

- [ ] **Step 2: Verificar que não há mais mock data no StockController**

Confirmar que `_items` não é mais inicializado com dados hardcoded.

- [ ] **Step 3: Commit final (se necessário)**

```bash
git add -A
git commit -m "chore: final verification of stock backend connection"
```
