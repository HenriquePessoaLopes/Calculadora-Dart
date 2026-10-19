import 'package:calculadora_nucleo/calculadora_nucleo.dart';

/// Mostra [texto] sem quebra de linha e devolve o que a pessoa digitou (`null` se a entrada acabou).
typedef Perguntar = String? Function(String texto);

/// Escreve uma linha na tela.
typedef Escrever = void Function(String linha);

/// A conversa da calculadora no terminal:
///
/// ```
/// Digite o primeiro número: 12
/// Digite a operação (+, -, *, /, ^): *
/// Digite o segundo número: 3
/// Resultado: 12 × 3 = 36
/// ```
///
/// Entrada errada não derruba o programa: aparece um `ERROR:` explicando o problema
/// e a pergunta é repetida. Digitar `sair` em qualquer pergunta encerra.
class SessaoDeTerminal {
  final Perguntar perguntar;
  final Escrever escrever;

  SessaoDeTerminal({required this.perguntar, required this.escrever});

  /// Roda a conversa até a pessoa sair (ou a entrada acabar).
  void executar() {
    escrever('=== Calculadora (terminal) ===');
    escrever('Digite "sair" em qualquer pergunta para encerrar.');

    while (true) {
      escrever('');
      final primeiro = _perguntarNumero('Digite o primeiro número: ');
      if (primeiro == null) break;

      final operacao = _perguntarOperacao();
      if (operacao == null) break;

      final segundo = _perguntarNumero('Digite o segundo número: ');
      if (segundo == null) break;

      _mostrarResultado(primeiro, operacao, segundo);

      if (!_querContinuar()) break;
    }

    escrever('');
    escrever('Até logo!');
  }

  void _mostrarResultado(double a, Operacao operacao, double b) {
    try {
      final resultado = calcular(a, operacao, b);
      escrever('Resultado: ${formatar(a)} ${operacao.simboloNaTela} ${formatar(b)} = ${formatar(resultado)}');
    } on ErroDeCalculo catch (erro) {
      escrever('ERROR: ${erro.mensagem}');
    }
  }

  /// Pergunta até receber um número válido. Devolve `null` se a pessoa quiser sair.
  double? _perguntarNumero(String pergunta) {
    while (true) {
      final resposta = _ler(pergunta);
      if (resposta == null) return null;

      final numero = lerNumero(resposta);
      if (numero != null) return numero;

      escrever(
        resposta.trim().isEmpty
            ? 'ERROR: você não digitou nada. Digite um número, por exemplo 12 ou 7,5.'
            : 'ERROR: "${resposta.trim()}" não é um número. Digite algo como 12 ou 7,5.',
      );
    }
  }

  Operacao? _perguntarOperacao() {
    while (true) {
      final resposta = _ler('Digite a operação (+, -, *, /, ^): ');
      if (resposta == null) return null;

      final operacao = Operacao.doTexto(resposta);
      if (operacao != null) return operacao;

      escrever(
        resposta.trim().isEmpty
            ? 'ERROR: você não digitou nada. Use + - * / ou ^.'
            : 'ERROR: "${resposta.trim()}" não é uma operação. Use + - * / ou ^.',
      );
    }
  }

  bool _querContinuar() {
    while (true) {
      final resposta = _ler('Fazer outra conta? (s/n): ');
      if (resposta == null) return false;

      switch (resposta.trim().toLowerCase()) {
        case 's' || 'sim':
          return true;
        case 'n' || 'nao' || 'não':
          return false;
        default:
          escrever('ERROR: responda com "s" para sim ou "n" para não.');
      }
    }
  }

  /// Lê uma resposta; devolve `null` quando a pessoa digita "sair" ou a entrada termina.
  String? _ler(String pergunta) {
    final resposta = perguntar(pergunta);
    if (resposta == null) return null;
    if (resposta.trim().toLowerCase() == 'sair') return null;
    return resposta;
  }
}
