/// Visual status of a stock item, derived from its occupancy rate
/// (quantity / capacity).
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

class StockItem {
  final String id;
  final String name;
  final String packageLabel;
  final int quantity;
  final int capacity;

  const StockItem({
    required this.id,
    required this.name,
    required this.packageLabel,
    required this.quantity,
    required this.capacity,
  });

  double get occupancyRatio => capacity == 0 ? 0 : quantity / capacity;

  StockStatus get status {
    if (quantity <= 0) return StockStatus.outOfStock;
    final ratio = occupancyRatio;
    if (ratio < 0.05) return StockStatus.critical;
    if (ratio < 0.15) return StockStatus.low;
    if (ratio < 0.30) return StockStatus.attention;
    if (ratio < 0.70) return StockStatus.adequate;
    return StockStatus.high;
  }

  bool get isOutOfStock => quantity <= 0;

  StockItem copyWith({int? quantity}) {
    return StockItem(
      id: id,
      name: name,
      packageLabel: packageLabel,
      quantity: quantity ?? this.quantity,
      capacity: capacity,
    );
  }
}
