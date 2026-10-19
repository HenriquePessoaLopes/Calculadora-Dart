import 'dart:io';

import 'package:calculadora_terminal/sessao_de_terminal.dart';

void main() {
  SessaoDeTerminal(
    perguntar: (texto) {
      stdout.write(texto);
      return stdin.readLineSync();
    },
    escrever: stdout.writeln,
  ).executar();
}
