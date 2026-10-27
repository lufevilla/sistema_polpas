import '../../src/rust/api/simple.dart' as api;
import '../../src/rust/error.dart';

String extrairMensagemErro(Object erro) {
  if (erro is AppError) {
    return api.extrairMensagemErro(erro: erro);
  }
  return erro.toString();
}
