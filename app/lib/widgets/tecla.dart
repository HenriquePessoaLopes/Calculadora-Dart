import 'package:flutter/material.dart';

import '../tema/cores.dart';

/// O tipo da tecla define a cor: números em cinza escuro, funções em cinza claro e operações em azul.
enum TipoDeTecla { numero, funcao, operador, igual }

class Tecla extends StatelessWidget {
  /// Identificador estável (usado na chave do widget e nos testes): `7`, `somar`, `igual`...
  final String id;

  /// O que aparece escrito na tecla.
  final String rotulo;

  /// Como um leitor de tela deve ler a tecla.
  final String descricao;

  final TipoDeTecla tipo;
  final VoidCallback onPressed;

  const Tecla({
    super.key,
    required this.id,
    required this.rotulo,
    required this.descricao,
    required this.tipo,
    required this.onPressed,
  });

  Color get _cor => switch (tipo) {
    TipoDeTecla.numero => CoresDaCalculadora.teclaNumero,
    TipoDeTecla.funcao => CoresDaCalculadora.teclaFuncao,
    TipoDeTecla.operador => CoresDaCalculadora.teclaOperador,
    TipoDeTecla.igual => CoresDaCalculadora.teclaIgual,
  };

  Color get _corDoTexto => tipo == TipoDeTecla.igual
      ? CoresDaCalculadora.textoSobreIgual
      : CoresDaCalculadora.textoPrincipal;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: descricao,
      excludeSemantics: true,
      onTap: onPressed,
      child: Material(
        color: _cor,
        borderRadius: BorderRadius.circular(22),
        elevation: 2,
        shadowColor: Colors.black54,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('tecla-$id'),
          onTap: onPressed,
          // A calculadora usa o teclado do computador diretamente; a tecla na tela só responde a toque/clique.
          canRequestFocus: false,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Center(
            child: Text(
              rotulo,
              style: TextStyle(
                color: _corDoTexto,
                fontSize: tipo == TipoDeTecla.numero ? 28 : 26,
                fontWeight: tipo == TipoDeTecla.numero
                    ? FontWeight.w400
                    : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
