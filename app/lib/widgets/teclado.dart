import 'package:calculadora_nucleo/calculadora_nucleo.dart';
import 'package:flutter/material.dart';

import 'tecla.dart';

/// O teclado na tela. Não guarda estado: cada tecla chama o método certo da [Calculadora]
/// e avisa a tela, por [aoApertar], para ela se redesenhar.
class Teclado extends StatelessWidget {
  final Calculadora calculadora;
  final VoidCallback aoApertar;

  const Teclado({
    super.key,
    required this.calculadora,
    required this.aoApertar,
  });

  static const double _espaco = 12;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: _espaco,
      children: [
        _linha([
          _funcao('C', 'C', 'limpar tudo', calculadora.limpar),
          _funcao('apagar', '⌫', 'apagar', calculadora.apagar),
          _funcao('porcento', '%', 'porcentagem', calculadora.porcentagem),
          _operador(Operacao.dividir, 'dividir'),
        ]),
        _linha([
          _numero(7),
          _numero(8),
          _numero(9),
          _operador(Operacao.multiplicar, 'multiplicar'),
        ]),
        _linha([
          _numero(4),
          _numero(5),
          _numero(6),
          _operador(Operacao.subtrair, 'subtrair'),
        ]),
        _linha([
          _numero(1),
          _numero(2),
          _numero(3),
          _operador(Operacao.somar, 'somar'),
        ]),
        _linha([
          _funcao('sinal', '±', 'trocar o sinal', calculadora.inverterSinal),
          _numero(0),
          _tecla(
            'virgula',
            ',',
            'vírgula',
            TipoDeTecla.numero,
            calculadora.virgula,
          ),
          _operador(Operacao.potencia, 'elevar a'),
        ]),
        _linha([
          _tecla('igual', '=', 'igual', TipoDeTecla.igual, calculadora.igual),
        ]),
      ],
    );
  }

  Widget _linha(List<Widget> teclas) {
    return Expanded(
      child: Row(
        spacing: _espaco,
        children: [for (final tecla in teclas) Expanded(child: tecla)],
      ),
    );
  }

  Widget _numero(int digito) => _tecla(
    '$digito',
    '$digito',
    '$digito',
    TipoDeTecla.numero,
    () => calculadora.digito(digito),
  );

  Widget _funcao(
    String id,
    String rotulo,
    String descricao,
    VoidCallback acao,
  ) => _tecla(id, rotulo, descricao, TipoDeTecla.funcao, acao);

  Widget _operador(Operacao operacao, String descricao) => _tecla(
    operacao.name,
    operacao.simboloNaTela,
    descricao,
    TipoDeTecla.operador,
    () => calculadora.operador(operacao),
  );

  Widget _tecla(
    String id,
    String rotulo,
    String descricao,
    TipoDeTecla tipo,
    VoidCallback acao,
  ) {
    return Tecla(
      id: id,
      rotulo: rotulo,
      descricao: descricao,
      tipo: tipo,
      onPressed: () {
        acao();
        aoApertar();
      },
    );
  }
}
