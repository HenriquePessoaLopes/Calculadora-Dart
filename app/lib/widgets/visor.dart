import 'package:flutter/material.dart';

import '../tema/cores.dart';

/// A tela da calculadora: a conta em andamento (pequena) e o número (grande) ou `ERROR`.
class Visor extends StatelessWidget {
  final String historico;
  final String valor;
  final String? mensagemDeErro;

  const Visor({
    super.key,
    required this.historico,
    required this.valor,
    this.mensagemDeErro,
  });

  bool get _emErro => mensagemDeErro != null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: _emErro ? 'Erro: $mensagemDeErro' : 'Resultado $valor',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        decoration: BoxDecoration(
          color: CoresDaCalculadora.painel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: CoresDaCalculadora.painelBorda),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: 24,
              child: Text(
                historico,
                key: const Key('historico'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CoresDaCalculadora.textoSecundario,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // O número ocupa o espaço que sobrar e encolhe se não couber (janela baixa ou número longo).
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  valor,
                  key: const Key('visor'),
                  maxLines: 1,
                  style: TextStyle(
                    color: _emErro
                        ? CoresDaCalculadora.erro
                        : CoresDaCalculadora.textoPrincipal,
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    letterSpacing: _emErro ? 4 : 0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 22,
              child: Text(
                mensagemDeErro ?? '',
                key: const Key('mensagem-de-erro'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CoresDaCalculadora.erro,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
