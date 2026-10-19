// Leitura e formatação de números no padrão brasileiro (vírgula como separador decimal).

final RegExp _formatoDeNumero = RegExp(r'^[+-]?(\d+[.,]?\d*|[.,]\d+)([eE][+-]?\d+)?$');

/// Lê um número digitado por uma pessoa: aceita `12`, `-3`, `7,5`, `7.5`, `.5` e `1e3`.
///
/// Devolve `null` para qualquer coisa que não seja um número finito
/// (texto, vazio, `NaN`, `Infinity`, `1,234.5`).
double? lerNumero(String texto) {
  final limpo = texto.trim().replaceAll(' ', '');
  if (!_formatoDeNumero.hasMatch(limpo)) return null;
  final valor = double.tryParse(limpo.replaceAll(',', '.'));
  if (valor == null || !valor.isFinite) return null;
  return valor;
}

/// Escreve um número para a tela: sem zeros sobrando, com vírgula decimal e sem
/// ruídos de ponto flutuante (`0,1 + 0,2` aparece como `0,3`, não `0,30000000000000004`).
String formatar(double valor) {
  if (valor == 0) return '0';

  final modulo = valor.abs();
  String texto;
  if (modulo >= 1e12 || modulo < 1e-6) {
    // Notação científica: 1,1529215e+18
    texto = valor.toStringAsExponential(8);
    final partes = texto.split('e');
    texto = '${_tirarZeros(partes[0])}e${partes[1]}';
  } else {
    texto = _tirarZeros(valor.toStringAsPrecision(12));
  }
  return texto.replaceAll('.', ',');
}

String _tirarZeros(String texto) {
  if (!texto.contains('.')) return texto;
  return texto.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
