import '../src/rust/api/pedidos_service.dart' as svc;
import '../src/rust/models/pedido.dart';

export '../src/rust/models/pedido.dart' show Pedido, ItemPedido;

Future<int> criarPedido({
  required int clienteId,
  required List<ItemPedido> itens,
}) {
  return svc.criarPedido(clienteId: clienteId, itens: itens);
}

Future<List<Pedido>> listarPedidos() {
  return svc.listarPedidos();
}

Future<void> excluirPedido({required int pedidoId}) {
  return svc.excluirPedido(pedidoId: pedidoId);
}
