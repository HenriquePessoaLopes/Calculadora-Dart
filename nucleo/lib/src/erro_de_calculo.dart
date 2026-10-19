/// Uma conta impossível (como dividir por zero). A [mensagem] já está pronta para mostrar ao usuário.
class ErroDeCalculo implements Exception {
  final String mensagem;

  const ErroDeCalculo(this.mensagem);

  @override
  String toString() => mensagem;
}
