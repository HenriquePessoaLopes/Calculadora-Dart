# Calculadora

Calculadora feita aplicando **princípios lógicos de programação**, na linguagem **Dart**, com **Flutter** como front-end. Ela existe em duas versões: uma **no terminal**, que vai perguntando "Digite o primeiro número:", e um **app com teclado na tela**, em azul e cinza. As duas usam o mesmo "cérebro" (a lógica), então fazem as contas e reagem aos erros exatamente do mesmo jeito.

**Tecnologias:** Dart 3 (lógica e terminal) · Flutter (interface, web, Android e Windows) · testes automatizados com `package:test` e `flutter_test`.

## Princípios de programação aplicados

- **Lógica separada da tela:** todas as regras (contas, validação, erros) ficam no `nucleo`, que não conhece terminal nem Flutter. A tela só mostra o resultado.
- **Máquina de estados:** o visor é uma pequena máquina de estados (digitando, aguardando o próximo número, resultado, erro). Cada tecla leva de um estado a outro, como numa calculadora de bolso.
- **Validação de entrada:** nada que o usuário digita é aceito sem checar (`abc`, vazio, vírgulas repetidas, `NaN`, `Infinity`).
- **Tratamento de exceções:** uma conta impossível lança um `ErroDeCalculo` com mensagem clara, e cada camada decide como mostrar (`ERROR:` no terminal, `ERROR` vermelho no app).
- **Reaproveitamento de código:** o mesmo núcleo serve ao terminal e ao app Flutter.
- **Testes:** 84 testes cobrem as contas, os erros, a conversa do terminal e a tela.

## A história

Tudo começou com um exercício de Dart bem simples: um programa de terminal de 35 linhas que lia dois números e uma operação. Ele funcionava... até alguém digitar `7,5` ou `abc`, quando quebrava com um erro cheio de linhas vermelhas e sem explicar nada.

Em vez de remendar, a calculadora foi refeita em três partes:

1. **O núcleo** (`nucleo/`): um pacote Dart puro que sabe fazer as contas, ler números do jeito que as pessoas digitam (com vírgula!) e dizer, em português, quando uma conta é impossível. Não tem tela nenhuma, então é fácil de testar.
2. **O terminal** (`terminal/`): conversa com a pessoa, pergunta cada coisa e, se a resposta estiver errada, mostra um `ERROR:` explicando e pergunta de novo, em vez de cair.
3. **O app** (`app/`): uma calculadora de verdade, com teclado na tela e visor, que mostra **ERROR** em vermelho quando a conta não existe. Também dá para usar o teclado do computador.

## O que ela faz

- Operações: `+`, `−`, `×`, `÷` e potência (`^`), mais `%`, trocar sinal (`±`), apagar e limpar.
- Decimais com **vírgula** (e aceita ponto também): `0,1 + 0,2` dá `0,3`, sem o ruído `0.30000000000000004`.
- Resultados inteiros sem casas (`36`, não `36.0`) e números gigantes em notação científica (`2^60 = 1,1529215e+18`).
- No app, as contas encadeiam como numa calculadora de bolso: `2 + 3 ×` já mostra `5`.

### Quando aparece ERROR

| Conta | Mensagem |
|---|---|
| `5 ÷ 0`, `0 ÷ 0` | Divisão por zero não existe. |
| `0 ^ 0` | 0 elevado a 0 é indefinido. |
| `0 ^ -2` | Divisão por zero não existe (0 elevado a um expoente negativo). |
| `-4 ^ 0,5` (raiz de negativo) | Essa conta não tem resultado entre os números reais. |
| `10 ^ 200` | O resultado é grande demais (o limite é 1e100). |

No **terminal**, entradas que não são números (`abc`, vazio, `1,2,3`) ou operações desconhecidas (`%`, `mais`) também mostram `ERROR:` e a pergunta se repete. No **app**, depois do ERROR basta apertar um número (ou `C`) para recomeçar.

## Como está organizado

```
Calculadora/
  nucleo/      # pacote Dart: contas, números, erros e a lógica do visor (50 testes)
  terminal/    # calculadora de terminal (14 testes)
  app/         # app Flutter com teclado na tela (20 testes)
  .vscode/     # configurações para rodar pelo VS Code (F5)
```

O `terminal` e o `app` dependem do `nucleo` (`path: ../nucleo`), por isso as contas e os erros são idênticos nos dois.

## Como rodar

**Você precisa do Flutter SDK** (que já traz o Dart): <https://docs.flutter.dev/get-started/install>. Depois de instalar, confira com `flutter --version`. Os comandos abaixo são do PowerShell, e os de terminal funcionam em qualquer sistema.

### Calculadora de terminal

```powershell
cd terminal
dart pub get
dart run bin/calculadora.dart
```

Exemplo de conversa:

```
=== Calculadora (terminal) ===
Digite "sair" em qualquer pergunta para encerrar.

Digite o primeiro número: abc
ERROR: "abc" não é um número. Digite algo como 12 ou 7,5.
Digite o primeiro número: 12
Digite a operação (+, -, *, /, ^): *
Digite o segundo número: 3
Resultado: 12 × 3 = 36
Fazer outra conta? (s/n): s

Digite o primeiro número: 5
Digite a operação (+, -, *, /, ^): /
Digite o segundo número: 0
ERROR: Divisão por zero não existe.
Fazer outra conta? (s/n): n

Até logo!
```

### App Flutter

```powershell
cd app
flutter pub get
flutter run -d chrome
```

Troque `chrome` por `windows` (precisa do Visual Studio com "Desenvolvimento para desktop com C++") ou pelo código de um celular/emulador Android (`flutter devices` lista os disponíveis). No computador, o teclado também funciona: números, `+ - * / ^`, vírgula ou ponto, `%`, `Enter` ou `=`, `Backspace` para apagar e `Esc` para limpar.

### Rodando pela IDE

**VS Code:** instale as extensões **Dart** e **Flutter**, abra a pasta `Calculadora` e aperte **F5**: aparecem as opções "Calculadora (terminal)" e "Calculadora (app Flutter)" (já configuradas em `.vscode/launch.json`; o terminal usa `"console": "terminal"` para você poder digitar as respostas). Se o VS Code não achar o SDK, aponte `dart.flutterSdkPath` para a pasta do Flutter.

**IntelliJ / Android Studio:** instale os plugins **Dart** e **Flutter**, configure o caminho do Flutter SDK em *Settings → Languages & Frameworks → Flutter* e abra a pasta `terminal` (clique com o botão direito em `bin/calculadora.dart` → *Run*) ou a pasta `app` (botão *Run* com o dispositivo escolhido).

### Testes

```powershell
cd nucleo;   dart test        # 50 testes: contas, erros, números e a lógica do visor
cd ../terminal; dart test     # 14 testes: a conversa do terminal, com respostas certas e erradas
cd ../app;   flutter test     # 20 testes: toques, teclado do computador, ERROR, cores e tamanhos de tela
```

## Decisões

- **Um núcleo compartilhado** em vez de repetir as contas no terminal e no app: um erro corrigido vale para os dois.
- **A lógica do visor não conhece a tela** (`Calculadora` no núcleo): o app só desenha o que ela devolve, e por isso dá para testar o comportamento do teclado sem abrir nenhuma janela.
- **Erros como exceções próprias** (`ErroDeCalculo`) com mensagem pronta para o usuário: nada de stack trace para quem só digitou algo errado.
- **Cores:** azul para as operações, cinzas para números e funções, e vermelho só para o ERROR.
