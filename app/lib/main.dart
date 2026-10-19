import 'package:flutter/material.dart';

import 'tela_calculadora.dart';
import 'tema/cores.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CoresDaCalculadora.fundo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CoresDaCalculadora.teclaOperador,
          brightness: Brightness.dark,
        ),
      ),
      home: const TelaCalculadora(),
    );
  }
}
