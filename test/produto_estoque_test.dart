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
