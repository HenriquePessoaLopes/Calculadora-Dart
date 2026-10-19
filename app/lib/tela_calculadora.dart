import 'dart:math' as math;

import 'package:calculadora_nucleo/calculadora_nucleo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tema/cores.dart';
import 'widgets/teclado.dart';
import 'widgets/visor.dart';

/// A tela única do app: visor em cima e teclado embaixo.
/// Também responde ao teclado do computador (números, `+ - * / ^`, vírgula, Enter, Backspace, Esc).
class TelaCalculadora extends StatefulWidget {
  const TelaCalculadora({super.key});

  @override
  State<TelaCalculadora> createState() => _TelaCalculadoraState();
}

class _TelaCalculadoraState extends State<TelaCalculadora> {
  final Calculadora _calculadora = Calculadora();

  void _atualizar(VoidCallback acao) => setState(acao);

  /// Traduz uma tecla física em uma ação da calculadora. Devolve `true` se a tecla foi usada.
  bool _tratarTecla(KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return false;

    final tecla = evento.logicalKey;
    if (tecla == LogicalKeyboardKey.backspace) {
      _atualizar(_calculadora.apagar);
      return true;
    }
    if (tecla == LogicalKeyboardKey.escape ||
        tecla == LogicalKeyboardKey.delete) {
      _atualizar(_calculadora.limpar);
      return true;
    }
    if (tecla == LogicalKeyboardKey.enter ||
        tecla == LogicalKeyboardKey.numpadEnter) {
      _atualizar(_calculadora.igual);
      return true;
    }

    final caractere = evento.character;
    if (caractere == null || caractere.isEmpty) return false;

    final digito = int.tryParse(caractere);
    if (digito != null && caractere.length == 1) {
      _atualizar(() => _calculadora.digito(digito));
      return true;
    }
    if (caractere == ',' || caractere == '.') {
      _atualizar(_calculadora.virgula);
      return true;
    }
    if (caractere == '=') {
      _atualizar(_calculadora.igual);
      return true;
    }
    if (caractere == '%') {
      _atualizar(_calculadora.porcentagem);
      return true;
    }
    if (caractere == 'c' || caractere == 'C') {
      _atualizar(_calculadora.limpar);
      return true;
    }
    final operacao = Operacao.doTexto(caractere);
    if (operacao != null) {
      _atualizar(() => _calculadora.operador(operacao));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoresDaCalculadora.fundo,
      body: Focus(
        autofocus: true,
        onKeyEvent: (_, evento) => _tratarTecla(evento)
            ? KeyEventResult.handled
            : KeyEventResult.ignored,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, restricoes) {
              // Em janelas muito baixas (celular deitado), rola em vez de espremer as teclas.
              final altura = math.max(restricoes.maxHeight, 560.0);
              return Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 420,
                      minHeight: altura,
                      maxHeight: altura,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        spacing: 16,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Visor(
                              historico: _calculadora.historico,
                              valor: _calculadora.visor,
                              mensagemDeErro: _calculadora.mensagemDeErro,
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Teclado(
                              calculadora: _calculadora,
                              aoApertar: () => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
