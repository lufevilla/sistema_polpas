import '../src/rust/api/estoque_service.dart';
import '../src/rust/models/pedido.dart';

export '../src/rust/models/pedido.dart' show Produto;

Future<void> entradaNoEstoque({required Produto produto}) {
  return entradaNoEstoqueService(produto: produto);
}

Future<List<Produto>> listagemDoEstoque() {
  return listagemDoEstoqueService();
}

Future<void> incluirItemEstoque({
  required String nomeMerc,
  required int quantidadeEst,
}) {
  return incluirItemEstoqueService(
    nomeMerc: nomeMerc,
    quantidadeEst: quantidadeEst,
  );
}

Future<void> excluirItemEstoque({required int itemId}) {
  return excluirItemEstoqueService(itemId: itemId);
}
