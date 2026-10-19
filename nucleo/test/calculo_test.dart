import 'package:calculadora_nucleo/calculadora_nucleo.dart';
import 'package:test/test.dart';

void main() {
  group('calcular', () {
    test('as quatro operações básicas', () {
      expect(calcular(12, Operacao.somar, 3), 15);
      expect(calcular(12, Operacao.subtrair, 20), -8);
      expect(calcular(12, Operacao.multiplicar, 3), 36);
      expect(calcular(12, Operacao.dividir, 4), 3);
    });

    test('potência, inclusive expoente negativo e fracionário', () {
      expect(calcular(2, Operacao.potencia, 10), 1024);
      expect(calcular(2, Operacao.potencia, -1), 0.5);
      expect(calcular(9, Operacao.potencia, 0.5), 3);
      expect(calcular(-2, Operacao.potencia, 3), -8);
    });

    test('decimais e números negativos', () {
      expect(calcular(7.5, Operacao.somar, 2.5), 10);
      expect(calcular(-3, Operacao.multiplicar, -4), 12);
    });

    test('nunca devolve "-0"', () {
      final r = calcular(-0.0, Operacao.multiplicar, 5);
      expect(r, 0);
      expect(r.isNegative, isFalse);
    });

    group('contas impossíveis viram ErroDeCalculo', () {
      void erro(double a, Operacao op, double b, String contem) {
        expect(
          () => calcular(a, op, b),
          throwsA(isA<ErroDeCalculo>().having((e) => e.mensagem, 'mensagem', contains(contem))),
          reason: '$a ${op.simbolo} $b',
        );
      }

      test('divisão por zero', () {
        erro(5, Operacao.dividir, 0, 'Divisão por zero');
        erro(0, Operacao.dividir, 0, 'Divisão por zero');
        erro(-5, Operacao.dividir, -0.0, 'Divisão por zero');
      });

      test('0 elevado a 0 e a expoente negativo', () {
        erro(0, Operacao.potencia, 0, 'indefinido');
        erro(0, Operacao.potencia, -2, 'Divisão por zero');
      });

      test('raiz de número negativo', () {
        erro(-4, Operacao.potencia, 0.5, 'números reais');
      });

      test('resultado grande demais', () {
        erro(10, Operacao.potencia, 101, 'grande demais');
        erro(1e60, Operacao.multiplicar, 1e60, 'grande demais');
        erro(9, Operacao.potencia, 1000, 'grande demais');
      });

      test('o limite é 1e100, inclusive', () {
        expect(calcular(10, Operacao.potencia, 100), 1e100);
      });

      test('entradas que não são números finitos', () {
        erro(double.infinity, Operacao.somar, 1, 'finitos');
        erro(1, Operacao.somar, double.nan, 'finitos');
      });
    });
  });

  group('Operacao.doTexto', () {
    test('reconhece os símbolos do teclado e os bonitos', () {
      expect(Operacao.doTexto('+'), Operacao.somar);
      expect(Operacao.doTexto('-'), Operacao.subtrair);
      expect(Operacao.doTexto('−'), Operacao.subtrair);
      expect(Operacao.doTexto('*'), Operacao.multiplicar);
      expect(Operacao.doTexto('x'), Operacao.multiplicar);
      expect(Operacao.doTexto('X'), Operacao.multiplicar);
      expect(Operacao.doTexto('×'), Operacao.multiplicar);
      expect(Operacao.doTexto('/'), Operacao.dividir);
      expect(Operacao.doTexto('÷'), Operacao.dividir);
      expect(Operacao.doTexto('^'), Operacao.potencia);
      expect(Operacao.doTexto('**'), Operacao.potencia);
      expect(Operacao.doTexto('  +  '), Operacao.somar);
    });

    test('devolve null para o que não é operação', () {
      for (final texto in ['', 'abc', '++', '=', '1', '%', 'mais']) {
        expect(Operacao.doTexto(texto), isNull, reason: texto);
      }
    });

    test('cada operação tem símbolo de teclado e de tela', () {
      expect(Operacao.multiplicar.simbolo, '*');
      expect(Operacao.multiplicar.simboloNaTela, '×');
      expect(Operacao.dividir.simboloNaTela, '÷');
    });
  });
}
