import 'package:calculadora_nucleo/calculadora_nucleo.dart';
import 'package:test/test.dart';

void main() {
  group('lerNumero', () {
    test('aceita inteiros, negativos e decimais com vírgula ou ponto', () {
      expect(lerNumero('12'), 12);
      expect(lerNumero('-3'), -3);
      expect(lerNumero('+4'), 4);
      expect(lerNumero('7,5'), 7.5);
      expect(lerNumero('7.5'), 7.5);
      expect(lerNumero('-0,25'), -0.25);
      expect(lerNumero(',5'), 0.5);
      expect(lerNumero('3,'), 3);
    });

    test('ignora espaços e aceita notação científica', () {
      expect(lerNumero('  12  '), 12);
      expect(lerNumero('1 000'), 1000);
      expect(lerNumero('1e3'), 1000);
      expect(lerNumero('2,5E-1'), 0.25);
    });

    test('recusa o que não é número', () {
      for (final texto in [
        '',
        '   ',
        'abc',
        '12a',
        '1,2,3',
        '1.234,5',
        '1,234.5',
        '--1',
        '+-1',
        '.',
        ',',
        'e5',
        '1e',
        '0x10',
        'NaN',
        'Infinity',
        '-Infinity',
        '1e999',
      ]) {
        expect(lerNumero(texto), isNull, reason: '"$texto"');
      }
    });
  });

  group('formatar', () {
    test('inteiros sem casas decimais', () {
      expect(formatar(36), '36');
      expect(formatar(-8), '-8');
      expect(formatar(0), '0');
      expect(formatar(-0.0), '0');
      expect(formatar(1024), '1024');
    });

    test('decimais com vírgula e sem zeros sobrando', () {
      expect(formatar(2.5), '2,5');
      expect(formatar(0.5), '0,5');
      expect(formatar(-7.25), '-7,25');
      expect(formatar(1 / 3), '0,333333333333');
    });

    test('esconde o ruído de ponto flutuante', () {
      expect(formatar(0.1 + 0.2), '0,3');
      expect(formatar(1.1 * 3), '3,3');
    });

    test('números grandes e pequenos usam notação científica', () {
      expect(formatar(123456789012), '123456789012');
      expect(formatar(1e12), '1e+12');
      expect(formatar(1152921504606846976), '1,1529215e+18');
      expect(formatar(0.0000001), '1e-7');
      expect(formatar(1e100), '1e+100');
    });

    test('o que se formata pode ser lido de volta', () {
      for (final v in [36.0, 2.5, -7.25, 0.3, 1e12, 1.5e-7, 1.152921504e18]) {
        expect(lerNumero(formatar(v)), closeTo(v, v.abs() * 1e-8), reason: '$v');
      }
    });
  });
}
