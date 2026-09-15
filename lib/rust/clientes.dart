import '../src/rust/api/clientes_service.dart';
import '../src/rust/api/simple.dart' as api;
import '../src/rust/error.dart';
import '../src/rust/models/cliente.dart';

export '../src/rust/models/cliente.dart' show Cliente, Endereco;

Future<void> incluirCliente({required Cliente cliente}) {
  return incluirClienteService(cliente: cliente);
}

Future<void> atualizarCliente({
  required Cliente cliente,
  required int clienteId,
}) {
  return atualizarClienteService(cliente: cliente, clienteId: clienteId);
}

Future<void> excluirCliente({
  required Cliente cliente,
  required int clienteId,
}) {
  return excluirClienteService(cliente: cliente, clienteId: clienteId);
}

Future<List<Cliente>> listarClientes() {
  return listarClientesService();
}

String extrairMensagemErro(Object e) {
  if (e is AppError) {
    return api.extrairMensagemErro(erro: e);
  }
  return e.toString();
}
