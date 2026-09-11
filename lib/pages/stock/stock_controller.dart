import 'package:flutter/foundation.dart';

import 'models/stock_item.dart';

class StockController extends ChangeNotifier {
  // TODO: replace mock with data from backend/local storage.
  final List<StockItem> _items = [
    const StockItem(
      id: 'passion_fruit',
      name: 'Maracujá',
      packageLabel: 'Pacote 1kg',
      quantity: 120,
      capacity: 150,
    ),
    const StockItem(
      id: 'mixed_berries',
      name: 'Frutas Vermelhas',
      packageLabel: 'Pacote 1kg',
      quantity: 15,
      capacity: 150,
    ),
    const StockItem(
      id: 'acerola',
      name: 'Acerola',
      packageLabel: 'Pacote 1kg',
      quantity: 85,
      capacity: 150,
    ),
    const StockItem(
      id: 'pineapple',
      name: 'Abacaxi',
      packageLabel: 'Pacote 1kg',
      quantity: 40,
      capacity: 150,
    ),
    const StockItem(
      id: 'pineapple_mint',
      name: 'Abacaxi c/ Hortelã',
      packageLabel: 'Pacote 1kg',
      quantity: 50,
      capacity: 150,
    ),
    const StockItem(
      id: 'cashew',
      name: 'Caju',
      packageLabel: 'Pacote 1kg',
      quantity: 0,
      capacity: 150,
    ),
    const StockItem(
      id: 'detox',
      name: 'Detox',
      packageLabel: 'Pacote 1kg',
      quantity: 30,
      capacity: 150,
    ),
    const StockItem(
      id: 'mango',
      name: 'Manga',
      packageLabel: 'Pacote 1kg',
      quantity: 110,
      capacity: 150,
    ),
    const StockItem(
      id: 'watermelon',
      name: 'Melancia',
      packageLabel: 'Pacote 1kg',
      quantity: 5,
      capacity: 150,
    ),
    const StockItem(
      id: 'strawberry',
      name: 'Morango',
      packageLabel: 'Pacote 1kg',
      quantity: 90,
      capacity: 150,
    ),
    const StockItem(
      id: 'guava',
      name: 'Goiaba',
      packageLabel: 'Pacote 1kg',
      quantity: 65,
      capacity: 150,
    ),
  ];

  // TODO: replace with real sales metric.
  final String _bestSellerId = 'passion_fruit';

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
      _items.firstWhere((item) => item.id == _bestSellerId).name;

  void increment(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      quantity: (_items[index].quantity + 1).clamp(0, _items[index].capacity),
    );
    notifyListeners();
  }

  void decrement(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      quantity: (_items[index].quantity - 1).clamp(0, _items[index].capacity),
    );
    notifyListeners();
  }

  void startNewBatch(String id) {
    // TODO: open new-batch registration flow.
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(quantity: _items[index].capacity);
    notifyListeners();
  }
}
