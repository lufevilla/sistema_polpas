import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_polpas/pages/stock/widgets/stock_item_card.dart';
import 'package:sistema_polpas/src/rust/models/pedido.dart';

const produtoEmEstoque = Produto(
  idMerc: 7,
  nomeMerc: 'Acerola',
  quantidadeEst: 3,
  quantidadeMinima: 10,
  valorUnitario: 8.5,
);

const produtoEmFalta = Produto(
  idMerc: 8,
  nomeMerc: 'Maracujá',
  quantidadeEst: 0,
  quantidadeMinima: 10,
  valorUnitario: 12,
);

Widget app({
  required Produto produto,
  VoidCallback? onEntrada,
  VoidCallback? onDecrement,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StockItemCard(
          produto: produto,
          onEntrada: onEntrada ?? () {},
          onDecrement: onDecrement ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('mostra produto em estoque e dispara ações', (tester) async {
    var entradas = 0;
    var saidas = 0;

    await tester.pumpWidget(
      app(
        produto: produtoEmEstoque,
        onEntrada: () => entradas++,
        onDecrement: () => saidas++,
      ),
    );

    expect(find.text('Acerola'), findsOneWidget);
    expect(find.text('R\$ 8,50'), findsOneWidget);
    expect(find.text('3 / 10 un'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.remove));

    expect(entradas, 1);
    expect(saidas, 1);
  });

  testWidgets('mostra Novo Lote quando o produto está em falta', (
    tester,
  ) async {
    var entradas = 0;

    await tester.pumpWidget(
      app(produto: produtoEmFalta, onEntrada: () => entradas++),
    );

    expect(find.text('Em Falta'), findsOneWidget);
    expect(find.text('Novo Lote'), findsOneWidget);

    await tester.tap(find.text('Novo Lote'));

    expect(entradas, 1);
  });
}
