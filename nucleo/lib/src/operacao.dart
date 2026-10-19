/// As operações que a calculadora sabe fazer.
enum Operacao {
  somar('+'),
  subtrair('-'),
  multiplicar('*'),
  dividir('/'),
  potencia('^');

  /// O que se digita no teclado do computador.
  final String simbolo;

  const Operacao(this.simbolo);

  /// Como a operação aparece na tela (sinais "bonitos").
  String get simboloNaTela => switch (this) {
        somar => '+',
        subtrair => '−',
        multiplicar => '×',
        dividir => '÷',
        potencia => '^',
      };

  /// Entende o que a pessoa digitou: `+ - * / ^`, mas também `x`, `×`, `÷`, `−` e `**`.
  /// Devolve `null` se não for uma operação conhecida.
  static Operacao? doTexto(String texto) {
    return switch (texto.trim().toLowerCase()) {
      '+' => somar,
      '-' || '−' || '–' => subtrair,
      '*' || 'x' || '×' => multiplicar,
      '/' || '÷' || ':' => dividir,
      '^' || '**' => potencia,
      _ => null,
    };
  }
}
