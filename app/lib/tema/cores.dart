import 'package:flutter/material.dart';

/// Paleta da calculadora: azuis e cinzas (e um vermelho só para o ERROR).
abstract final class CoresDaCalculadora {
  // Fundo e painel do visor
  static const Color fundo = Color(0xFF161D27);
  static const Color painel = Color(0xFF1F2A38);
  static const Color painelBorda = Color(0xFF2E3C4E);

  // Teclas
  static const Color teclaNumero = Color(0xFF354355); // cinza-azulado
  static const Color teclaFuncao = Color(
    0xFF5E7088,
  ); // cinza claro (C, ⌫, %, ±)
  static const Color teclaOperador = Color(0xFF2F80ED); // azul
  static const Color teclaIgual = Color(0xFF56A0FF); // azul claro

  // Textos
  static const Color textoPrincipal = Color(0xFFFFFFFF);
  static const Color textoSecundario = Color(0xFF8FA3BA);
  static const Color textoSobreIgual = Color(0xFF0B1B30);

  // Erro
  static const Color erro = Color(0xFFFF7A7A);
}
