# Calculadora (app Flutter)

Calculadora com teclado na tela, em azul e cinza, e `ERROR` quando a conta é impossível.

O passo a passo para rodar, os testes e a história do projeto estão no [README da pasta principal](../README.md).

```powershell
flutter pub get
flutter run -d chrome
```

Código em `lib/`: `main.dart` (app e tema), `tela_calculadora.dart` (visor + teclado + teclado do computador), `widgets/` (visor, teclado e tecla) e `tema/cores.dart` (a paleta). As contas ficam no pacote `../nucleo`.
