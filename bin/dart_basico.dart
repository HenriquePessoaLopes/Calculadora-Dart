import 'dart:io';

void main(List<String> arguments) {

  String? entrada = stdin.readLineSync();

  if (entrada == null || entrada.trim().isEmpty) {
    print('Expressão inválida!');
    return;
  }


  List<String> partes = entrada.split(' ').where((e) => e.isNotEmpty).toList();

  // Verifica se a expressão começa e termina com número
  if (partes.length < 3 || partes.length % 2 == 0) {
    print('Expressão inválida!');
    return;
  }

  double resultado = double.parse(partes[0]);
  for (int i = 1; i < partes.length; i += 2) {
    String operador = partes[i];
    double numero = double.parse(partes[i + 1]);

    switch (operador) {
      case '+':
        resultado += numero;
        break;
      case '-':
        resultado -= numero;
        break;
      case '*':
        resultado *= numero;
        break;
      case '/':
        if (numero == 0) {
          print('Erro: Divisão por zero!');
          return;
        }
        resultado /= numero;
        break;
      default:
        print('Operador inválido: $operador');
        return;
    }
  }

  print('Resultado: $entrada = $resultado');
}