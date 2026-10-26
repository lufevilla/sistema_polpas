# Estoque com Produto e Movimentações — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Usar `Produto` no estoque e na Home, removendo `StockItem`, e registrar entradas de estoque via pop-up com quantidade e valor unitário da compra.

**Architecture:** O frontend passa a consumir `Produto` gerado pelo Rust e uma extensão compartilhada com as regras de status. O estoque usa os services já existentes (`entradaNoEstoque`, `saidaEstoque`, `incluirItemEstoque`, `listagemDoEstoque`). Nenhum arquivo Rust é alterado.

**Tech Stack:** Flutter/Dart, flutter_rust_bridge gerado, Rust/SQLite (inalterado), flutter_lints.

---

## Pré-requisitos e baseline

- Branch atual: `front-end_implementacao`.
- `flutter analyze` hoje falha apenas por causa de `lib/pages/stock/stock_page.dart:122` e `:124` (código incompleto em andamento). Esses erros serão corrigidos na Task 2.
- `rust/src/**` não deve ser modificado.
- Os arquivos `lib/rust/*.dart` já estão deletados no working tree e **não** fazem parte deste plano.

---

### Task 1: Extensão `ProdutoEstoque` e testes

**Files:**
- Create: `lib/core/models/produto_estoque.dart`
- Test: `test/produto_estoque_test.dart`

- [ ] **Step 1: Escrever o teste que falha**

Create `test/produto_estoque_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_polpas/core/models/produto_estoque.dart';
import 'package:sistema_polpas/src/rust/models/pedido.dart';

Produto produto({
  int quantidade = 50,
  int minimo = 100,
  double valor = 12.5,
}) {
  return Produto(
    idMerc: 1,
    nomeMerc: 'Maracujá',
    quantidadeEst: quantidade,
    quantidadeMinima: minimo,
    valorUnitario: valor,
  );
}

void main() {
  test('calcula ocupação, progresso e rótulo de quantidade', () {
    final item = produto(quantidade: 50, minimo: 100);

    expect(item.occupancyRatio, 0.5);
    expect(item.progress, 0.5);
    expect(item.quantityLabel, '50 u.');
    expect(item.isOutOfStock, isFalse);
    expect(item.isLow, isFalse);
    expect(item.status, StockStatus.adequate);
  });

  test('limita o progresso em 1 quando passa do mínimo', () {
    expect(produto(quantidade: 150, minimo: 100).progress, 1.0);
  });

  test('classifica estoque baixo e crítico', () {
    expect(produto(quantidade: 10, minimo: 100).status, StockStatus.low);
    expect(produto(quantidade: 10, minimo: 100).isLow, isTrue);
    expect(produto(quantidade: 4, minimo: 100).status, StockStatus.critical);
    expect(produto(quantidade: 4, minimo: 100).isLow, isTrue);
  });

  test('classifica estoque zerado como em falta', () {
    final item = produto(quantidade: 0, minimo: 100);

    expect(item.isOutOfStock, isTrue);
    expect(item.status, StockStatus.outOfStock);
    expect(item.isLow, isFalse);
  });

  test('não divide por zero quando o mínimo é zero', () {
    expect(produto(quantidade: 10, minimo: 0).occupancyRatio, 0);
  });

  test('rótulos de status permanecem iguais aos atuais', () {
    expect(StockStatus.high.label, 'Estoque Alto');
    expect(StockStatus.adequate.label, 'Adequado');
    expect(StockStatus.attention.label, 'Atenção');
    expect(StockStatus.low.label, 'Estoque Baixo');
    expect(StockStatus.critical.label, 'Crítico');
    expect(StockStatus.outOfStock.label, 'Em Falta');
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run:

```bash
flutter test test/produto_estoque_test.dart
```

Expected: FAIL com erro de import — o arquivo `lib/core/models/produto_estoque.dart` ainda não existe.

- [ ] **Step 3: Criar a extensão**

Create `lib/core/models/produto_estoque.dart`:

```dart
import '../../src/rust/models/pedido.dart';

enum StockStatus { high, adequate, attention, low, critical, outOfStock }

extension StockStatusLabel on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.high:
        return 'Estoque Alto';
      case StockStatus.adequate:
        return 'Adequado';
      case StockStatus.attention:
        return 'Atenção';
      case StockStatus.low:
        return 'Estoque Baixo';
      case StockStatus.critical:
        return 'Crítico';
      case StockStatus.outOfStock:
        return 'Em Falta';
    }
  }
}

extension ProdutoEstoque on Produto {
  double get occupancyRatio {
    final minimo = quantidadeMinima.toInt();
    if (minimo == 0) return 0;
    return quantidadeEst.toInt() / minimo;
  }

  StockStatus get status {
    if (quantidadeEst.toInt() <= 0) return StockStatus.outOfStock;
    final ratio = occupancyRatio;
    if (ratio < 0.05) return StockStatus.critical;
    if (ratio < 0.15) return StockStatus.low;
    if (ratio < 0.30) return StockStatus.attention;
    if (ratio < 0.70) return StockStatus.adequate;
    return StockStatus.high;
  }

  bool get isOutOfStock => quantidadeEst.toInt() <= 0;

  bool get isLow =>
      status == StockStatus.low || status == StockStatus.critical;

  double get progress => occupancyRatio.clamp(0.0, 1.0).toDouble();

  String get quantityLabel => '${quantidadeEst.toInt()} u.';
}
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run:

```bash
flutter test test/produto_estoque_test.dart
```

Expected: PASS — 6 testes.

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/produto_estoque.dart test/produto_estoque_test.dart
git commit -m "feat(stock): add Produto stock extensions"
```

---

### Task 2: Estoque usando `Produto` e pop-up de entrada

**Files:**
- Modify: `lib/pages/stock/stock_controller.dart`
- Modify: `lib/pages/stock/widgets/stock_item_card.dart`
- Modify: `lib/pages/stock/widgets/stock_form_modal.dart`
- Create: `lib/pages/stock/widgets/stock_movimento_modal.dart`
- Modify: `lib/pages/stock/stock_page.dart`
- Delete: `lib/pages/stock/models/stock_item.dart`
- Test: `test/stock_movimento_modal_test.dart`

- [ ] **Step 1: Escrever o teste do pop-up que falha**

Create `test/stock_movimento_modal_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_polpas/pages/stock/widgets/stock_movimento_modal.dart';
import 'package:sistema_polpas/src/rust/models/pedido.dart';

const produtoTeste = Produto(
  idMerc: 7,
  nomeMerc: 'Acerola',
  quantidadeEst: 3,
  quantidadeMinima: 10,
  valorUnitario: 8.5,
);

void main() {
  testWidgets('abre vazio, valida e devolve quantidade e valor', (
    tester,
  ) async {
    int? quantidadeSalva;
    double? valorSalvo;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  mostrarModalEntradaEstoque(
                    context: context,
                    produto: produtoTeste,
                    aoSalvar: (quantidade, valorUnitario) {
                      quantidadeSalva = quantidade;
                      valorSalvo = valorUnitario;
                    },
                  );
                },
                child: const Text('Abrir entrada'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir entrada'));
    await tester.pumpAndSettle();

    expect(find.text('Entrada no estoque'), findsOneWidget);
    expect(find.text('Acerola'), findsOneWidget);

    await tester.tap(find.text('Registrar entrada'));
    await tester.pumpAndSettle();

    expect(find.text('Quantidade inválida'), findsOneWidget);
    expect(find.text('Valor inválido'), findsOneWidget);
    expect(quantidadeSalva, isNull);
    expect(valorSalvo, isNull);

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '5');
    await tester.enterText(campos.at(1), '12,50');
    await tester.tap(find.text('Registrar entrada'));
    await tester.pumpAndSettle();

    expect(quantidadeSalva, 5);
    expect(valorSalvo, 12.5);
    expect(find.text('Entrada no estoque'), findsNothing);
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run:

```bash
flutter test test/stock_movimento_modal_test.dart
```

Expected: FAIL — `stock_movimento_modal.dart` ainda não existe.

- [ ] **Step 3: Criar o pop-up de entrada**

Create `lib/pages/stock/widgets/stock_movimento_modal.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/src/rust/models/pedido.dart';

Future<void> mostrarModalEntradaEstoque({
  required BuildContext context,
  required Produto produto,
  required void Function(int quantidade, double valorUnitario) aoSalvar,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EntradaEstoqueModal(
      produto: produto,
      aoSalvar: aoSalvar,
    ),
  );
}

class _EntradaEstoqueModal extends StatefulWidget {
  final Produto produto;
  final void Function(int quantidade, double valorUnitario) aoSalvar;

  const _EntradaEstoqueModal({
    required this.produto,
    required this.aoSalvar,
  });

  @override
  State<_EntradaEstoqueModal> createState() => _EntradaEstoqueModalState();
}

class _EntradaEstoqueModalState extends State<_EntradaEstoqueModal> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _valorUnitarioController = TextEditingController();

  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorUnitarioController.dispose();
    super.dispose();
  }

  void _aoSalvar() {
    if (!_formKey.currentState!.validate()) return;

    final quantidade = int.parse(_quantidadeController.text.trim());
    final valorUnitario = double.parse(
      _valorUnitarioController.text.trim().replaceAll(',', '.'),
    );

    widget.aoSalvar(quantidade, valorUnitario);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.8,
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
                  const Text(
                    'Entrada no estoque',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.produto.nomeMerc,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _campo(
                    controlador: _quantidadeController,
                    label: 'Quantidade',
                    tipoTeclado: TextInputType.number,
                    validador: (value) {
                      final quantidade = int.tryParse(value?.trim() ?? '');
                      if (quantidade == null || quantidade <= 0) {
                        return 'Quantidade inválida';
                      }
                      return null;
                    },
                  ),
                  _campo(
                    controlador: _valorUnitarioController,
                    label: 'Valor unitário da compra (R\$)',
                    tipoTeclado: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    acaoTeclado: TextInputAction.done,
                    validador: (value) {
                      final valor = double.tryParse(
                        (value ?? '').trim().replaceAll(',', '.'),
                      );
                      if (valor == null || valor <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
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
                        'Registrar entrada',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
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
    TextInputAction acaoTeclado = TextInputAction.next,
    required String? Function(String?)? validador,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controlador,
        keyboardType: tipoTeclado,
        textInputAction: acaoTeclado,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        validator: validador,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: AppColors.cardBackground,
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
}
```

- [ ] **Step 4: Rodar o teste do pop-up e confirmar que passa**

Run:

```bash
flutter test test/stock_movimento_modal_test.dart
```

Expected: PASS — 1 teste.

- [ ] **Step 5: Reescrever o `StockController` para `Produto`**

Replace the entire content of `lib/pages/stock/stock_controller.dart` with:

```dart
import 'package:flutter/foundation.dart';
import '../../core/models/produto_estoque.dart';
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
      _erro = e.toString();
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
      _erro = e.toString();
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
      _erro = e.toString();
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
      _erro = e.toString();
      notifyListeners();
    }
  }

  Future<void> excluirItem(Produto produto) async {
    try {
      await svc.excluirItem(idMerc: produto.idMerc);
      await carregarEstoque();
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
    }
  }
}
```

- [ ] **Step 6: Reescrever o card para `Produto`**

Replace the entire content of `lib/pages/stock/widgets/stock_item_card.dart` with:

```dart
import 'package:flutter/material.dart';

import '../../../core/models/produto_estoque.dart';
import '../../../core/theme/app_colors.dart';
import '../../../src/rust/models/pedido.dart';

class StockItemCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback onEntrada;
  final VoidCallback onDecrement;

  const StockItemCard({
    super.key,
    required this.produto,
    required this.onEntrada,
    required this.onDecrement,
  });

  Color get _statusColor {
    switch (produto.status) {
      case StockStatus.high:
      case StockStatus.adequate:
        return AppColors.success;
      case StockStatus.attention:
        return AppColors.gold;
      case StockStatus.low:
      case StockStatus.critical:
        return AppColors.danger;
      case StockStatus.outOfStock:
        return AppColors.textMuted;
    }
  }

  bool get _isCritical => produto.isLow;

  String get _precoFormatado =>
      'R\$ ${produto.valorUnitario.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    if (produto.isOutOfStock) return _buildOutOfStock();
    return _buildInStock();
  }

  Widget _buildInStock() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCritical
              ? AppColors.danger.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nomeMerc,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      _precoFormatado,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                status: produto.status,
                color: _statusColor,
                isCritical: _isCritical,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ocupação',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                '${produto.quantidadeEst.toInt()} / ${produto.quantidadeMinima.toInt()} un',
                style: TextStyle(
                  fontSize: 11,
                  color: _isCritical ? AppColors.danger : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: produto.progress,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(_statusColor),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _isCritical ? AppColors.danger : AppColors.textDark,
                    fontFamily: 'monospace',
                  ),
                  children: [
                    TextSpan(text: '${produto.quantidadeEst.toInt()}'),
                    const TextSpan(
                      text: ' un',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.remove,
                    background: AppColors.background,
                    foreground: AppColors.textDark,
                    onTap: onDecrement,
                  ),
                  const SizedBox(width: 6),
                  _RoundIconButton(
                    icon: Icons.add,
                    background: AppColors.headerStart,
                    foreground: Colors.white,
                    onTap: onEntrada,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStock() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Opacity(
        opacity: 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nomeMerc,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      _precoFormatado,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Em Falta',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ocupação',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  '0 / ${produto.quantidadeMinima.toInt()} un',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                value: 0,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation(AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '0 un',
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
                OutlinedButton(
                  onPressed: onEntrada,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.headerStart,
                    side: BorderSide(
                      color: AppColors.headerStart.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Novo Lote'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StockStatus status;
  final Color color;
  final bool isCritical;

  const _StatusBadge({
    required this.status,
    required this.color,
    required this.isCritical,
  });

  @override
  Widget build(BuildContext context) {
    final background = isCritical
        ? AppColors.danger.withValues(alpha: 0.12)
        : color.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCritical) ...[
            Icon(Icons.warning_amber_rounded, size: 12, color: color),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: foreground),
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Adaptar o modal de novo item para `Produto`**

Replace the entire content of `lib/pages/stock/widgets/stock_form_modal.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/src/rust/models/pedido.dart';

Future<void> mostrarModalNovoItemEstoque({
  required BuildContext context,
  required void Function(Produto produto) aoSalvar,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StockFormModal(aoSalvar: aoSalvar),
  );
}

class _StockFormModal extends StatefulWidget {
  final void Function(Produto produto) aoSalvar;

  const _StockFormModal({required this.aoSalvar});

  @override
  State<_StockFormModal> createState() => _StockFormModalState();
}

class _StockFormModalState extends State<_StockFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeInicialController = TextEditingController();
  final _quantidadeMinimaController = TextEditingController();
  final _valorUnitarioController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeInicialController.dispose();
    _quantidadeMinimaController.dispose();
    _valorUnitarioController.dispose();
    super.dispose();
  }

  void _aoSalvar() {
    if (!_formKey.currentState!.validate()) return;

    final produto = Produto(
      idMerc: 0,
      nomeMerc: _nomeController.text.trim(),
      quantidadeEst: int.parse(_quantidadeInicialController.text.trim()),
      quantidadeMinima: int.parse(_quantidadeMinimaController.text.trim()),
      valorUnitario: double.parse(
        _valorUnitarioController.text.trim().replaceAll(',', '.'),
      ),
    );

    widget.aoSalvar(produto);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
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
                  const Text(
                    'Novo item de estoque',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _campo(
                    controlador: _nomeController,
                    label: 'Nome do produto',
                  ),
                  _campo(
                    controlador: _quantidadeInicialController,
                    label: 'Quantidade inicial',
                    tipoTeclado: TextInputType.number,
                    validador: _validaInteiroPositivo,
                  ),
                  _campo(
                    controlador: _quantidadeMinimaController,
                    label: 'Quantidade mínima',
                    tipoTeclado: TextInputType.number,
                    validador: _validaInteiroPositivo,
                  ),
                  _campo(
                    controlador: _valorUnitarioController,
                    label: 'Valor unitário de venda (R\$)',
                    tipoTeclado: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    acaoTeclado: TextInputAction.done,
                    validador: _validaDecimalPositivo,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
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
                        'Adicionar item',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validaInteiroPositivo(String? value) {
    final numero = int.tryParse(value?.trim() ?? '');
    if (numero == null || numero <= 0) return 'Valor inválido';
    return null;
  }

  String? _validaDecimalPositivo(String? value) {
    final numero = double.tryParse(
      (value ?? '').trim().replaceAll(',', '.'),
    );
    if (numero == null || numero <= 0) return 'Valor inválido';
    return null;
  }

  Widget _campo({
    required TextEditingController controlador,
    required String label,
    TextInputType tipoTeclado = TextInputType.text,
    TextInputAction acaoTeclado = TextInputAction.next,
    String? Function(String?)? validador,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controlador,
        keyboardType: tipoTeclado,
        textInputAction: acaoTeclado,
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        validator: validador ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: AppColors.cardBackground,
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
}
```

- [ ] **Step 8: Atualizar a `StockPage`**

Replace the entire content of `lib/pages/stock/stock_page.dart` with:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'stock_controller.dart';
import 'widgets/stock_bestseller_card.dart';
import 'widgets/stock_form_modal.dart';
import 'widgets/stock_item_card.dart';
import 'widgets/stock_low_stock_card.dart';
import 'widgets/stock_movimento_modal.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _controller = StockController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_aoControladorMudar);
    _controller.carregarEstoque();
  }

  @override
  void dispose() {
    _controller.removeListener(_aoControladorMudar);
    _controller.dispose();
    super.dispose();
  }

  void _aoControladorMudar() => setState(() {});

  void _abrirModalNovoItem() {
    mostrarModalNovoItemEstoque(
      context: context,
      aoSalvar: (produto) {
        _controller.incluirItem(produto);
      },
    );
  }

  void _abrirModalEntrada(Produto produto) {
    mostrarModalEntradaEstoque(
      context: context,
      produto: produto,
      aoSalvar: (quantidade, valorUnitario) {
        _controller.registrarEntrada(
          produto: produto,
          quantidade: quantidade,
          valorUnitario: valorUnitario,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.carregando) {
      return Container(
        color: AppColors.background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller.erro.isNotEmpty) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                const SizedBox(height: 16),
                Text(
                  _controller.erro,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _controller.carregarEstoque,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildSummary()),
          ),
          if (_controller.items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    'Nenhum item no estoque.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final produto = _controller.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StockItemCard(
                      produto: produto,
                      onEntrada: () => _abrirModalEntrada(produto),
                      onDecrement: () => _controller.decrement(produto),
                    ),
                  );
                }, childCount: _controller.items.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirModalNovoItem,
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.textDark,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StockLowStockCard(count: _controller.lowStockCount),
        const SizedBox(height: 12),
        StockBestsellerCard(name: _controller.bestSellerName),
      ],
    );
  }
}
```

- [ ] **Step 9: Remover o modelo antigo**

Run:

```bash
rm lib/pages/stock/models/stock_item.dart
```

- [ ] **Step 10: Rodar análise e testes**

Run:

```bash
flutter analyze
flutter test test/produto_estoque_test.dart test/stock_movimento_modal_test.dart
```

Expected: `flutter analyze` sem erros; testes PASS.

- [ ] **Step 11: Commit**

```bash
git add lib/pages/stock lib/core/models/produto_estoque.dart test/produto_estoque_test.dart test/stock_movimento_modal_test.dart
git commit -m "feat(stock): use Produto and add entry movement modal"
```

---

### Task 3: Home usando `Produto`

**Files:**
- Modify: `lib/pages/home/home_controller.dart`
- Modify: `lib/pages/home/home_page.dart`
- Modify: `lib/pages/home/widgets/home_widgets.dart`

- [ ] **Step 1: Reescrever o `HomeController`**

Replace the entire content of `lib/pages/home/home_controller.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:sistema_polpas/pages/clients/clients_page.dart';
import 'package:sistema_polpas/pages/sales/sales_page.dart';
import 'package:sistema_polpas/pages/stock/stock_page.dart';
import '../../core/models/produto_estoque.dart';
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

  List<Produto> get highlightedStock =>
      List.unmodifiable(_highlightedStock);
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
      _erro = e.toString();
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
```

- [ ] **Step 2: Atualizar o ciclo de vida da `HomePage`**

In `lib/pages/home/home_page.dart`, inside `_HomePageState`, add this before `build`:

```dart
  @override
  void initState() {
    super.initState();
    _controller.addListener(_aoControladorMudar);
    _controller.carregarEstoque();
  }

  @override
  void dispose() {
    _controller.removeListener(_aoControladorMudar);
    _controller.dispose();
    super.dispose();
  }

  void _aoControladorMudar() => setState(() {});
```

Then replace the `StockHighlightSection` block inside `build` with:

```dart
                if (_controller.carregando)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_controller.erro.isNotEmpty)
                  Text(
                    _controller.erro,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  )
                else
                  StockHighlightSection(
                    items: _controller.highlightedStock,
                    onVerEstoqueCompleto: () =>
                        _controller.onVerEstoqueCompletoTap(context),
                  ),
```

- [ ] **Step 3: Atualizar os widgets da Home**

At the top of `lib/pages/home/widgets/home_widgets.dart`, replace the import block with:

```dart
import 'package:flutter/material.dart';
import '../../../core/models/produto_estoque.dart';
import '../../../core/theme/app_colors.dart';
import '../../../src/rust/models/pedido.dart';
```

Then replace the `StockHighlightSection` class signature and item loop:

```dart
class StockHighlightSection extends StatelessWidget {
  final List<Produto> items;
  final VoidCallback onVerEstoqueCompleto;

  const StockHighlightSection({
    super.key,
    required this.items,
    required this.onVerEstoqueCompleto,
  });
```

Inside its `Column`, replace the `for` loop with:

```dart
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Nenhum item no estoque.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            )
          else
            for (final item in items) ...[
              StockItemTile(produto: item),
              const SizedBox(height: 14),
            ],
```

Then replace the `StockItemTile` class with:

```dart
class StockItemTile extends StatelessWidget {
  final Produto produto;

  const StockItemTile({super.key, required this.produto});

  static const _placeholderColors = [
    Color(0xFFE8A33D),
    Color(0xFF8B1E1E),
    Color(0xFF4C7A34),
    Color(0xFF6B4C9A),
  ];

  Color get _placeholderColor =>
      _placeholderColors[produto.nomeMerc.hashCode.abs() %
          _placeholderColors.length];

  @override
  Widget build(BuildContext context) {
    final isLow = produto.isLow;
    return Row(
      children: [
        // TODO: substituir por Image.asset/Image.network real do produto.
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _placeholderColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                produto.nomeMerc,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: produto.progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEFE6D8),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLow ? AppColors.danger : AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          produto.quantityLabel,
          style: TextStyle(
            color: isLow ? AppColors.danger : AppColors.textMuted,
            fontWeight: isLow ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Rodar análise e testes**

Run:

```bash
flutter analyze
flutter test test/produto_estoque_test.dart test/stock_movimento_modal_test.dart
```

Expected: `flutter analyze` sem erros; testes PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/pages/home
git commit -m "feat(home): load stock highlights from Produto"
```

---

### Task 4: Verificação final

**Files:**
- No new files.

- [ ] **Step 1: Confirmar que o backend não foi tocado**

Run:

```bash
git diff --name-only -- rust/src
```

Expected: saída vazia.

- [ ] **Step 2: Verificar Rust**

Run:

```bash
cd rust && cargo check
```

Expected: `Finished` sem erros.

- [ ] **Step 3: Verificar Dart**

Run:

```bash
flutter analyze
flutter test test/produto_estoque_test.dart test/stock_movimento_modal_test.dart
```

Expected: `No issues found!` e testes PASS.

- [ ] **Step 4: Conferir referências antigas**

Run:

```bash
grep -rn "StockItem\|stock_item" lib/pages/stock lib/pages/home lib/core
```

Expected: apenas o nome do widget `StockItemCard`/`stock_item_card.dart` e `StockItemTile`; nenhuma classe de modelo `StockItem` e nenhum import de `models/stock_item.dart`.

- [ ] **Step 5: Commit final (se necessário)**

Se a verificação exigir algum ajuste:

```bash
git add -A
git commit -m "chore(stock): fix verification issues"
```

Se não houver ajustes, não criar commit vazio.

---

## Critérios de conclusão

- Estoque e Home usam `Produto` gerado pelo Rust.
- `lib/pages/stock/models/stock_item.dart` não existe.
- O botão `+` e o botão `Novo Lote` abrem o pop-up de entrada com quantidade e valor vazios.
- O pop-up valida quantidade inteira > 0 e valor decimal > 0.
- Salvar o pop-up chama `entradaNoEstoque` e recarrega o estoque.
- O botão `-` continua chamando `saidaEstoque` com quantidade 1.
- Nenhum arquivo em `rust/src/` foi alterado.
- `flutter analyze` sem erros e testes novos passando.
