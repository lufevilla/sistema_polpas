import '../src/rust/api/pedidos_service.dart';
import '../src/rust/models/pedido.dart';

export '../src/rust/models/pedido.dart' show Pedido, ItemPedido;

Future<void> novoPedido({
  required Pedido pedido,
  required List<ItemPedido> itens,
}) {
  return novoPedidoService(pedido: pedido, itens: itens);
}

Future<List<Pedido>> listarPedidos() {
  return listarPedidosService();
}

Future<void> excluirPedido({required int pedidoId}) {
  return excluirPedidoService(pedidoId: pedidoId);
}
