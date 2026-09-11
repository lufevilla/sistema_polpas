/// TODO: Substituir por dados reais vindos da Session/AppConfig
/// (nome e subtítulo do negócio configurados no cadastro do dono).
/// Como o header agora é fixo pro app inteiro, esse é o lugar certo
/// pra buscar essa informação (ex: uma vez, no início da sessão).
class StoreInfo {
  final String name;
  final String subtitle;

  const StoreInfo({required this.name, required this.subtitle});
}

class AppHeaderController {
  // TODO: buscar da Session (dono/funcionário) via AuthGate.
  final StoreInfo storeInfo = const StoreInfo(
    name: 'Graça e Paz',
    subtitle: 'Polpas de Fruta',
  );
}
