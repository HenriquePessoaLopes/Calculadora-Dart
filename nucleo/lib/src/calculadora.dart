import 'calculo.dart';
import 'erro_de_calculo.dart';
import 'numeros.dart';
import 'operacao.dart';

/// O que uma calculadora de bolso faz ao apertar cada tecla.
///
/// É só lógica (sem tela): o app Flutter chama os métodos e desenha [visor] e [historico].
/// Quando a conta é impossível, o [visor] mostra `ERROR` e [mensagemDeErro] explica o motivo;
/// a próxima tecla de dígito (ou `C`) começa de novo.
class Calculadora {
  /// Quantidade máxima de dígitos que cabem em um número digitado.
  static const int maximoDeDigitos = 15;

  String _entrada = '0';
  double? _acumulado;
  Operacao? _operacao;
  bool _novaEntrada = true;
  String _historico = '';
  String? _mensagemDeErro;

  /// O número grande da tela, ou `ERROR`.
  String get visor => _mensagemDeErro != null ? 'ERROR' : _entrada;

  /// A linha pequena acima do visor, como `12 ×` ou `12 × 3 =`.
  String get historico => _historico;

  /// Explica por que o visor mostra `ERROR` (ou `null` se está tudo certo).
  String? get mensagemDeErro => _mensagemDeErro;

  bool get emErro => _mensagemDeErro != null;

  // ---------- teclas ----------

  /// Tecla de dígito, de 0 a 9.
  void digito(int numero) {
    assert(numero >= 0 && numero <= 9, 'dígito fora de 0 a 9');
    _recomecarSeErro();
    if (_novaEntrada) {
      if (_operacao == null) _historico = '';
      _entrada = '$numero';
      _novaEntrada = false;
    } else if (_entrada == '0') {
      _entrada = '$numero';
    } else if (_entrada == '-0') {
      _entrada = '-$numero';
    } else if (_quantidadeDeDigitos(_entrada) < maximoDeDigitos) {
      _entrada += '$numero';
    }
  }

  /// Tecla da vírgula decimal.
  void virgula() {
    _recomecarSeErro();
    if (_novaEntrada) {
      if (_operacao == null) _historico = '';
      _entrada = '0,';
      _novaEntrada = false;
    } else if (!_entrada.contains(',') && !_entrada.contains('e')) {
      _entrada += ',';
    }
  }

  /// Tecla de operação (`+ − × ÷ ^`). Se já havia uma conta pendente, resolve-a primeiro (`2 + 3 ×` mostra 5).
  void operador(Operacao operacao) {
    if (emErro) return;

    if (_operacao != null && !_novaEntrada) {
      // Encadeamento: 2 + 3 [×] -> calcula 2 + 3 antes de seguir.
      try {
        _acumulado = calcular(_acumulado!, _operacao!, _valorDaEntrada);
        _entrada = formatar(_acumulado!);
      } on ErroDeCalculo catch (erro) {
        _falhar(erro.mensagem);
        return;
      }
    } else if (_operacao == null) {
      _acumulado = _valorDaEntrada;
    }
    // Se apertou duas operações seguidas, a segunda só troca a primeira.

    _operacao = operacao;
    _novaEntrada = true;
    _historico = '${formatar(_acumulado!)} ${operacao.simboloNaTela}';
  }

  /// Tecla de igual.
  void igual() {
    if (emErro || _operacao == null) return;

    final a = _acumulado!;
    final b = _valorDaEntrada; // "5 + =" usa o próprio 5 como segundo número
    final operacao = _operacao!;
    try {
      final resultado = calcular(a, operacao, b);
      _historico = '${formatar(a)} ${operacao.simboloNaTela} ${formatar(b)} =';
      _entrada = formatar(resultado);
      _acumulado = null;
      _operacao = null;
      _novaEntrada = true;
    } on ErroDeCalculo catch (erro) {
      _falhar(erro.mensagem);
    }
  }

  /// Tecla `C`: limpa tudo.
  void limpar() {
    _entrada = '0';
    _acumulado = null;
    _operacao = null;
    _novaEntrada = true;
    _historico = '';
    _mensagemDeErro = null;
  }

  /// Tecla de apagar o último dígito.
  void apagar() {
    if (emErro) {
      limpar();
      return;
    }
    if (_novaEntrada) return; // não apaga o resultado de uma conta
    _entrada = _entrada.substring(0, _entrada.length - 1);
    if (_entrada.isEmpty || _entrada == '-') _entrada = '0';
  }

  /// Tecla `±`: troca o sinal do número na tela.
  void inverterSinal() {
    if (emErro) return;
    if (_novaEntrada && _operacao != null) {
      // "5 + ±": começa o segundo número já negativo (como as calculadoras de bolso).
      _entrada = '-0';
      _novaEntrada = false;
      return;
    }
    if (_entrada == '0') return;
    _entrada = _entrada.startsWith('-') ? _entrada.substring(1) : '-$_entrada';
    if (_novaEntrada && _operacao == null) _historico = '';
  }

  /// Tecla `%`: divide o número na tela por 100.
  void porcentagem() {
    if (emErro) return;
    _entrada = formatar(_valorDaEntrada / 100);
    _novaEntrada = true;
  }

  // ---------- internos ----------

  double get _valorDaEntrada => lerNumero(_entrada) ?? 0;

  void _recomecarSeErro() {
    if (emErro) limpar();
  }

  void _falhar(String mensagem) {
    _mensagemDeErro = mensagem;
    _entrada = '0';
    _acumulado = null;
    _operacao = null;
    _novaEntrada = true;
    _historico = '';
  }

  int _quantidadeDeDigitos(String texto) => texto.replaceAll(RegExp(r'[^0-9]'), '').length;
}
