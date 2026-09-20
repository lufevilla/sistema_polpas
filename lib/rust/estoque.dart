import '../src/rust/api/estoque_service.dart' as svc;
import '../src/rust/models/pedido.dart';

export '../src/rust/models/pedido.dart' show Produto;

Future<void> entradaEstoque({
  required int idMerc,
  required int quantidadeAAdicionar,
}) {
  return svc.entradaNoEstoque(
    idMerc: idMerc,
    quantidadeAAdicionar: quantidadeAAdicionar,
  );
}

Future<List<Produto>> carregarEstoque() {
  return svc.listagemDoEstoque();
}

Future<void> incluirItemEstoque({required Produto produto}) {
  return svc.incluirItemEstoque(produto: produto);
}

Future<void> excluirItemEstoque({required int idMerc}) {
  return svc.excluirItem(idMerc: idMerc);
}

Future<void> saidaEstoque({
  required int idMerc,
  required int quantidadeSaida,
}) {
  return svc.saidaEstoque(
    idMerc: idMerc,
    quantidadeSaida: quantidadeSaida,
  );
}
