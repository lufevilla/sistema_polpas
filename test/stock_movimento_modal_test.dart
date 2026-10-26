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
