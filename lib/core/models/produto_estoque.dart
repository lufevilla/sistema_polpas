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
