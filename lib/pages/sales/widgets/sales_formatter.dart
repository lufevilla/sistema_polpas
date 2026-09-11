/// Formata uma data como no print: "12 DE OUTUBRO, 2023".
/// TODO: se o app passar a usar `intl`, trocar por DateFormat pt_BR.
///
String formatarDataPedido(DateTime data) {
  const meses = [
    'JANEIRO',
    'FEVEREIRO',
    'MARÇO',
    'ABRIL',
    'MAIO',
    'JUNHO',
    'JULHO',
    'AGOSTO',
    'SETEMBRO',
    'OUTUBRO',
    'NOVEMBRO',
    'DEZEMBRO',
  ];
  final dia = data.day.toString().padLeft(2, '0');
  final mes = meses[data.month - 1];
  return '$dia DE $mes, ${data.year}';
}

/// Formata um valor em reais: "R\$ 148,00".
String formatarValorReais(double valor) {
  final fixo = valor.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $fixo';
}
