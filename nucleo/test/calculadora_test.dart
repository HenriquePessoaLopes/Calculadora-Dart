import 'package:calculadora_nucleo/calculadora_nucleo.dart';
import 'package:test/test.dart';

/// Digita um número tecla por tecla: `digitar(c, '12,5')`.
void digitar(Calculadora c, String numero) {
  for (final caractere in numero.split('')) {
    if (caractere == ',') {
      c.virgula();
    } else if (caractere == '-') {
      c.inverterSinal();
    } else {
      c.digito(int.parse(caractere));
    }
  }
}

void main() {
  late Calculadora c;

  setUp(() => c = Calculadora());

  test('começa em 0, sem histórico e sem erro', () {
    expect(c.visor, '0');
    expect(c.historico, '');
    expect(c.emErro, isFalse);
    expect(c.mensagemDeErro, isNull);
  });

  group('digitando números', () {
    test('forma o número e não deixa zeros à esquerda', () {
      digitar(c, '007');
      expect(c.visor, '7');
      digitar(c, '05');
      expect(c.visor, '705');
    });

    test('vírgula: uma só, e "0," quando é a primeira tecla', () {
      c.virgula();
      expect(c.visor, '0,');
      digitar(c, '5');
      c.virgula();
      c.digito(2);
      expect(c.visor, '0,52');
    });

    test('limita a $_max dígitos', () {
      digitar(c, '1234567890123456789');
      expect(c.visor, '123456789012345');
    });

    test('apagar remove o último dígito e volta a 0 quando acaba', () {
      digitar(c, '123');
      c.apagar();
      expect(c.visor, '12');
      c.apagar();
      c.apagar();
      expect(c.visor, '0');
      c.apagar();
      expect(c.visor, '0');
    });

    test('± troca o sinal e não faz nada com o zero', () {
      c.inverterSinal();
      expect(c.visor, '0');
      digitar(c, '8');
      c.inverterSinal();
      expect(c.visor, '-8');
      c.inverterSinal();
      expect(c.visor, '8');
    });

    test('apagar um número negativo de um dígito volta a 0', () {
      digitar(c, '8');
      c.inverterSinal();
      c.apagar();
      expect(c.visor, '0');
    });
  });

  group('contas', () {
    test('12 × 3 = 36, com histórico', () {
      digitar(c, '12');
      c.operador(Operacao.multiplicar);
      expect(c.historico, '12 ×');
      digitar(c, '3');
      c.igual();
      expect(c.visor, '36');
      expect(c.historico, '12 × 3 =');
    });

    test('decimais: 7,5 + 2,5 = 10', () {
      digitar(c, '7,5');
      c.operador(Operacao.somar);
      digitar(c, '2,5');
      c.igual();
      expect(c.visor, '10');
    });

    test('0,1 + 0,2 mostra 0,3', () {
      digitar(c, '0,1');
      c.operador(Operacao.somar);
      digitar(c, '0,2');
      c.igual();
      expect(c.visor, '0,3');
    });

    test('operação em cadeia resolve a conta pendente: 2 + 3 × 4 = 20', () {
      digitar(c, '2');
      c.operador(Operacao.somar);
      digitar(c, '3');
      c.operador(Operacao.multiplicar);
      expect(c.visor, '5');
      expect(c.historico, '5 ×');
      digitar(c, '4');
      c.igual();
      expect(c.visor, '20');
    });

    test('duas operações seguidas: vale a última', () {
      digitar(c, '9');
      c.operador(Operacao.somar);
      c.operador(Operacao.subtrair);
      digitar(c, '4');
      c.igual();
      expect(c.visor, '5');
    });

    test('"5 + =" usa o próprio 5 como segundo número', () {
      digitar(c, '5');
      c.operador(Operacao.somar);
      c.igual();
      expect(c.visor, '10');
    });

    test('depois do resultado, dá para continuar a conta com ele', () {
      digitar(c, '6');
      c.operador(Operacao.multiplicar);
      digitar(c, '7');
      c.igual();
      c.operador(Operacao.somar);
      digitar(c, '8');
      c.igual();
      expect(c.visor, '50');
    });

    test('depois do resultado, um dígito começa um número novo', () {
      digitar(c, '6');
      c.operador(Operacao.multiplicar);
      digitar(c, '7');
      c.igual();
      digitar(c, '9');
      expect(c.visor, '9');
      expect(c.historico, '');
    });

    test('igual sem operação não faz nada', () {
      digitar(c, '42');
      c.igual();
      expect(c.visor, '42');
    });

    test('segundo número negativo: 5 × ±3 = -15', () {
      digitar(c, '5');
      c.operador(Operacao.multiplicar);
      c.inverterSinal();
      digitar(c, '3');
      c.igual();
      expect(c.visor, '-15');
    });

    test('potência: 2 ^ 10 = 1024', () {
      digitar(c, '2');
      c.operador(Operacao.potencia);
      digitar(c, '10');
      c.igual();
      expect(c.visor, '1024');
    });

    test('% divide o número da tela por 100', () {
      digitar(c, '50');
      c.porcentagem();
      expect(c.visor, '0,5');
    });

    test('resultado grande vai para notação científica e continua usável', () {
      digitar(c, '2');
      c.operador(Operacao.potencia);
      digitar(c, '60');
      c.igual();
      expect(c.visor, '1,1529215e+18');
      c.operador(Operacao.dividir);
      digitar(c, '2');
      c.igual();
      expect(c.emErro, isFalse);
    });
  });

  group('ERROR para contas impossíveis', () {
    void provocarDivisaoPorZero() {
      digitar(c, '5');
      c.operador(Operacao.dividir);
      digitar(c, '0');
      c.igual();
    }

    test('divisão por zero mostra ERROR e a explicação', () {
      provocarDivisaoPorZero();
      expect(c.visor, 'ERROR');
      expect(c.emErro, isTrue);
      expect(c.mensagemDeErro, contains('Divisão por zero'));
    });

    test('0 ÷ 0 também', () {
      digitar(c, '0');
      c.operador(Operacao.dividir);
      digitar(c, '0');
      c.igual();
      expect(c.visor, 'ERROR');
    });

    test('o erro também aparece ao encadear: 5 ÷ 0 +', () {
      digitar(c, '5');
      c.operador(Operacao.dividir);
      digitar(c, '0');
      c.operador(Operacao.somar);
      expect(c.visor, 'ERROR');
    });

    test('raiz de negativo e resultado grande demais', () {
      digitar(c, '4');
      c.inverterSinal();
      c.operador(Operacao.potencia);
      digitar(c, '0,5');
      c.igual();
      expect(c.visor, 'ERROR');

      c.limpar();
      digitar(c, '10');
      c.operador(Operacao.potencia);
      digitar(c, '200');
      c.igual();
      expect(c.visor, 'ERROR');
      expect(c.mensagemDeErro, contains('grande demais'));
    });

    test('durante o erro, operadores e igual são ignorados', () {
      provocarDivisaoPorZero();
      c.operador(Operacao.somar);
      c.igual();
      c.inverterSinal();
      c.porcentagem();
      expect(c.visor, 'ERROR');
    });

    test('um dígito depois do erro recomeça do zero', () {
      provocarDivisaoPorZero();
      c.digito(7);
      expect(c.visor, '7');
      expect(c.emErro, isFalse);
      expect(c.mensagemDeErro, isNull);
    });

    test('C e apagar também saem do erro', () {
      provocarDivisaoPorZero();
      c.limpar();
      expect(c.visor, '0');
      provocarDivisaoPorZero();
      c.apagar();
      expect(c.visor, '0');
    });

    test('depois do erro dá para fazer uma conta nova normalmente', () {
      provocarDivisaoPorZero();
      digitar(c, '8');
      c.operador(Operacao.dividir);
      digitar(c, '4');
      c.igual();
      expect(c.visor, '2');
    });
  });

  test('limpar zera tudo, inclusive uma conta pendente', () {
    digitar(c, '9');
    c.operador(Operacao.somar);
    digitar(c, '1');
    c.limpar();
    expect(c.visor, '0');
    expect(c.historico, '');
    c.igual();
    expect(c.visor, '0');
  });
}

const _max = Calculadora.maximoDeDigitos;
