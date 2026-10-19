import 'dart:math' as math;

import 'erro_de_calculo.dart';
import 'operacao.dart';

/// Resultados com valor absoluto acima disso são considerados grandes demais.
const double limiteDoResultado = 1e100;

/// Faz a conta `a <operação> b`.
///
/// Lança [ErroDeCalculo] quando a conta é impossível:
/// divisão por zero, `0^0`, raiz de número negativo (potência com expoente fracionário)
/// e resultados grandes demais.
double calcular(double a, Operacao operacao, double b) {
  if (!a.isFinite || !b.isFinite) {
    throw const ErroDeCalculo('Só números finitos são aceitos.');
  }

  final resultado = switch (operacao) {
    Operacao.somar => a + b,
    Operacao.subtrair => a - b,
    Operacao.multiplicar => a * b,
    Operacao.dividir => b == 0
        ? throw const ErroDeCalculo('Divisão por zero não existe.')
        : a / b,
    Operacao.potencia => _potencia(a, b),
  };

  if (resultado.isNaN) {
    throw const ErroDeCalculo('Essa conta não tem resultado entre os números reais.');
  }
  if (resultado.isInfinite || resultado.abs() > limiteDoResultado) {
    throw const ErroDeCalculo('O resultado é grande demais.');
  }
  // Evita mostrar "-0".
  return resultado == 0 ? 0.0 : resultado;
}

double _potencia(double base, double expoente) {
  if (base == 0 && expoente == 0) {
    throw const ErroDeCalculo('0 elevado a 0 é indefinido.');
  }
  if (base == 0 && expoente < 0) {
    throw const ErroDeCalculo('Divisão por zero não existe (0 elevado a um expoente negativo).');
  }
  return math.pow(base, expoente).toDouble();
}
