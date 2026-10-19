import 'package:calculadora_app/main.dart';
import 'package:calculadora_app/tema/cores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Finder tecla(String id) => find.byKey(Key('tecla-$id'));

String visor(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('visor'))).data!;

String historico(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('historico'))).data!;

String mensagemDeErro(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('mensagem-de-erro'))).data!;

/// Toca em uma sequência de teclas, pelos ids: `['7', 'multiplicar', '8', 'igual']`.
Future<void> tocar(WidgetTester tester, List<String> ids) async {
  for (final id in ids) {
    await tester.tap(tecla(id));
    await tester.pump();
  }
}

Future<void> abrir(WidgetTester tester) async {
  await tester.pumpWidget(const CalculadoraApp());
  await tester.pump();
}

/// Digita uma tecla do teclado do computador (com o caractere que ela produz).
Future<void> digitar(
  WidgetTester tester,
  LogicalKeyboardKey tecla, {
  String? caractere,
}) async {
  await tester.sendKeyDownEvent(tecla, character: caractere);
  await tester.sendKeyUpEvent(tecla);
  await tester.pump();
}

void main() {
  testWidgets('começa em 0 e mostra todas as teclas', (tester) async {
    await abrir(tester);

    expect(visor(tester), '0');
    expect(historico(tester), '');
    for (final id in [
      ...List.generate(10, (i) => '$i'),
      'C',
      'apagar',
      'porcento',
      'sinal',
      'virgula',
      'igual',
      'somar',
      'subtrair',
      'multiplicar',
      'dividir',
      'potencia',
    ]) {
      expect(tecla(id), findsOneWidget, reason: 'tecla $id');
    }
  });

  testWidgets('7 × 8 = 56', (tester) async {
    await abrir(tester);
    await tocar(tester, ['7', 'multiplicar']);
    expect(historico(tester), '7 ×');
    await tocar(tester, ['8', 'igual']);

    expect(visor(tester), '56');
    expect(historico(tester), '7 × 8 =');
  });

  testWidgets('decimais com vírgula: 7,5 + 2,5 = 10', (tester) async {
    await abrir(tester);
    await tocar(tester, [
      '7',
      'virgula',
      '5',
      'somar',
      '2',
      'virgula',
      '5',
      'igual',
    ]);

    expect(visor(tester), '10');
  });

  testWidgets('0,1 + 0,2 mostra 0,3', (tester) async {
    await abrir(tester);
    await tocar(tester, [
      '0',
      'virgula',
      '1',
      'somar',
      '0',
      'virgula',
      '2',
      'igual',
    ]);

    expect(visor(tester), '0,3');
  });

  testWidgets('apagar, trocar sinal, porcentagem e C', (tester) async {
    await abrir(tester);
    await tocar(tester, ['1', '2', '3', 'apagar']);
    expect(visor(tester), '12');
    await tocar(tester, ['sinal']);
    expect(visor(tester), '-12');
    await tocar(tester, ['porcento']);
    expect(visor(tester), '-0,12');
    await tocar(tester, ['C']);
    expect(visor(tester), '0');
  });

  group('ERROR', () {
    testWidgets('divisão por zero mostra ERROR em vermelho e explica', (
      tester,
    ) async {
      await abrir(tester);
      await tocar(tester, ['5', 'dividir', '0', 'igual']);

      expect(visor(tester), 'ERROR');
      expect(mensagemDeErro(tester), contains('Divisão por zero'));
      final texto = tester.widget<Text>(find.byKey(const Key('visor')));
      expect(texto.style!.color, CoresDaCalculadora.erro);
    });

    testWidgets('0 elevado a 0 e raiz de número negativo também dão ERROR', (
      tester,
    ) async {
      await abrir(tester);
      await tocar(tester, ['0', 'potencia', '0', 'igual']);
      expect(visor(tester), 'ERROR');

      await tocar(tester, [
        'C',
        '4',
        'sinal',
        'potencia',
        '0',
        'virgula',
        '5',
        'igual',
      ]);
      expect(visor(tester), 'ERROR');
      expect(mensagemDeErro(tester), contains('números reais'));
    });

    testWidgets('resultado grande demais dá ERROR', (tester) async {
      await abrir(tester);
      await tocar(tester, ['1', '0', 'potencia', '2', '0', '0', 'igual']);

      expect(visor(tester), 'ERROR');
      expect(mensagemDeErro(tester), contains('grande demais'));
    });

    testWidgets('um dígito depois do erro recomeça; C também limpa', (
      tester,
    ) async {
      await abrir(tester);
      await tocar(tester, ['5', 'dividir', '0', 'igual']);
      await tocar(tester, ['9']);
      expect(visor(tester), '9');
      expect(mensagemDeErro(tester), '');

      await tocar(tester, ['dividir', '0', 'igual', 'C']);
      expect(visor(tester), '0');
      expect(mensagemDeErro(tester), '');
    });

    testWidgets('a mensagem some quando a conta volta ao normal', (
      tester,
    ) async {
      await abrir(tester);
      expect(mensagemDeErro(tester), '');
    });
  });

  group('teclado do computador', () {
    testWidgets('digita uma conta: 6 * 7 e Enter', (tester) async {
      await abrir(tester);
      await digitar(tester, LogicalKeyboardKey.digit6, caractere: '6');
      await digitar(tester, LogicalKeyboardKey.numpadMultiply, caractere: '*');
      await digitar(tester, LogicalKeyboardKey.digit7, caractere: '7');
      await digitar(tester, LogicalKeyboardKey.enter);

      expect(visor(tester), '42');
      expect(historico(tester), '6 × 7 =');
    });

    testWidgets('vírgula ou ponto, + e - , Backspace e Escape', (tester) async {
      await abrir(tester);
      await digitar(tester, LogicalKeyboardKey.digit1, caractere: '1');
      await digitar(tester, LogicalKeyboardKey.period, caractere: '.');
      await digitar(tester, LogicalKeyboardKey.digit5, caractere: '5');
      await digitar(tester, LogicalKeyboardKey.numpadAdd, caractere: '+');
      await digitar(tester, LogicalKeyboardKey.digit2, caractere: '2');
      await digitar(tester, LogicalKeyboardKey.digit9, caractere: '9');
      await digitar(tester, LogicalKeyboardKey.backspace);
      expect(visor(tester), '2');
      await digitar(tester, LogicalKeyboardKey.numpadEnter);
      expect(visor(tester), '3,5');

      await digitar(tester, LogicalKeyboardKey.escape);
      expect(visor(tester), '0');
    });

    testWidgets('divisão por zero pelo teclado também dá ERROR', (
      tester,
    ) async {
      await abrir(tester);
      await digitar(tester, LogicalKeyboardKey.digit5, caractere: '5');
      await digitar(tester, LogicalKeyboardKey.slash, caractere: '/');
      await digitar(tester, LogicalKeyboardKey.digit0, caractere: '0');
      await digitar(tester, LogicalKeyboardKey.equal, caractere: '=');

      expect(visor(tester), 'ERROR');
    });

    testWidgets('teclas que não são da calculadora são ignoradas', (
      tester,
    ) async {
      await abrir(tester);
      await digitar(tester, LogicalKeyboardKey.keyQ, caractere: 'q');
      await digitar(tester, LogicalKeyboardKey.space, caractere: ' ');
      await digitar(tester, LogicalKeyboardKey.shiftLeft);

      expect(visor(tester), '0');
    });
  });

  group('visual', () {
    testWidgets('cores: azul nas operações, cinza nos números e nas funções', (
      tester,
    ) async {
      await abrir(tester);

      Color corDa(String id) {
        final material = tester.widget<Material>(
          find.ancestor(of: tecla(id), matching: find.byType(Material)).first,
        );
        return material.color!;
      }

      expect(corDa('7'), CoresDaCalculadora.teclaNumero);
      expect(corDa('C'), CoresDaCalculadora.teclaFuncao);
      expect(corDa('somar'), CoresDaCalculadora.teclaOperador);
      expect(corDa('igual'), CoresDaCalculadora.teclaIgual);
    });

    for (final tamanho in const [
      Size(360, 640),
      Size(390, 844),
      Size(800, 600),
      Size(1280, 800),
      Size(640, 360),
    ]) {
      testWidgets(
        'cabe sem estourar em ${tamanho.width.toInt()}x${tamanho.height.toInt()}',
        (tester) async {
          tester.view.physicalSize = tamanho;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await abrir(tester);
          await tocar(tester, [
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
            '9',
          ]);

          expect(tester.takeException(), isNull);
          expect(visor(tester), '999999999999999');
        },
      );
    }
  });
}
