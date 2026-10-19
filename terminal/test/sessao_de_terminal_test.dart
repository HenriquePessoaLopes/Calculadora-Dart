import 'package:calculadora_terminal/sessao_de_terminal.dart';
import 'package:test/test.dart';

/// Roda a sessão com respostas "digitadas" de antemão e devolve tudo o que foi escrito na tela.
String conversar(List<String> respostas) {
  final fila = List.of(respostas);
  final tela = StringBuffer();

  SessaoDeTerminal(
    perguntar: (texto) {
      tela.write(texto);
      if (fila.isEmpty) return null; // entrada acabou (Ctrl+D)
      final resposta = fila.removeAt(0);
      tela.writeln(resposta); // no terminal de verdade, o que a pessoa digita aparece
      return resposta;
    },
    escrever: tela.writeln,
  ).executar();

  return tela.toString();
}

void main() {
  test('uma conta completa: 12 * 3', () {
    final tela = conversar(['12', '*', '3', 'n']);
    expect(tela, contains('=== Calculadora (terminal) ==='));
    expect(tela, contains('Digite o primeiro número: 12'));
    expect(tela, contains('Digite a operação (+, -, *, /, ^): *'));
    expect(tela, contains('Digite o segundo número: 3'));
    expect(tela, contains('Resultado: 12 × 3 = 36'));
    expect(tela, contains('Até logo!'));
  });

  test('aceita decimais com vírgula e mostra o resultado com vírgula', () {
    expect(conversar(['7,5', '+', '2', 'n']), contains('Resultado: 7,5 + 2 = 9,5'));
  });

  test('0,1 + 0,2 não mostra ruído de ponto flutuante', () {
    expect(conversar(['0,1', '+', '0,2', 'n']), contains('Resultado: 0,1 + 0,2 = 0,3'));
  });

  test('divisão por zero mostra ERROR e o programa continua', () {
    final tela = conversar(['5', '/', '0', 's', '8', '/', '2', 'n']);
    expect(tela, contains('ERROR: Divisão por zero não existe.'));
    expect(tela, contains('Resultado: 8 ÷ 2 = 4'));
  });

  test('outras contas impossíveis também dão ERROR', () {
    expect(conversar(['0', '^', '0', 'n']), contains('ERROR: 0 elevado a 0 é indefinido.'));
    expect(conversar(['-4', '^', '0,5', 'n']), contains('ERROR: Essa conta não tem resultado'));
    expect(conversar(['10', '^', '200', 'n']), contains('ERROR: O resultado é grande demais.'));
  });

  test('texto no lugar do número: ERROR e a pergunta se repete', () {
    final tela = conversar(['abc', '12', '+', '1', 'n']);
    expect(tela, contains('ERROR: "abc" não é um número.'));
    expect(tela, contains('Resultado: 12 + 1 = 13'));
    // a pergunta aparece de novo depois do erro
    expect('Digite o primeiro número: '.allMatches(tela), hasLength(2));
  });

  test('entrada vazia também é erro', () {
    expect(conversar(['', '1', '+', '1', 'n']), contains('ERROR: você não digitou nada.'));
  });

  test('operação inválida: ERROR e a pergunta se repete', () {
    final tela = conversar(['2', '%', 'mais', '+', '3', 'n']);
    expect(tela, contains('ERROR: "%" não é uma operação.'));
    expect(tela, contains('ERROR: "mais" não é uma operação.'));
    expect(tela, contains('Resultado: 2 + 3 = 5'));
  });

  test('entende x, × e ÷ como operações', () {
    expect(conversar(['6', 'x', '7', 'n']), contains('Resultado: 6 × 7 = 42'));
    expect(conversar(['6', '÷', '3', 'n']), contains('Resultado: 6 ÷ 3 = 2'));
  });

  test('vários números inválidos em sequência não derrubam nada', () {
    final tela = conversar(['a', 'b', '1,2,3', '1.234,5', '3', '*', '4', 'n']);
    expect('ERROR: '.allMatches(tela), hasLength(4));
    expect(tela, contains('Resultado: 3 × 4 = 12'));
  });

  test('"sair" encerra em qualquer pergunta', () {
    expect(conversar(['sair']), contains('Até logo!'));
    expect(conversar(['12', 'SAIR']), contains('Até logo!'));
    final tela = conversar(['12', '+', 'sair']);
    expect(tela, contains('Até logo!'));
    expect(tela, isNot(contains('Resultado')));
  });

  test('fim da entrada (Ctrl+D) encerra sem erro', () {
    expect(conversar([]), contains('Até logo!'));
    expect(conversar(['12', '+']), contains('Até logo!'));
  });

  test('"Fazer outra conta?" aceita s/sim/n/não e repete se a resposta for estranha', () {
    final tela = conversar(['1', '+', '1', 'talvez', 'SIM', '2', '+', '2', 'não']);
    expect(tela, contains('ERROR: responda com "s" para sim ou "n" para não.'));
    expect(tela, contains('Resultado: 1 + 1 = 2'));
    expect(tela, contains('Resultado: 2 + 2 = 4'));
    expect(tela, contains('Até logo!'));
  });

  test('números grandes aparecem em notação científica', () {
    expect(conversar(['2', '^', '60', 'n']), contains('= 1,1529215e+18'));
  });
}
