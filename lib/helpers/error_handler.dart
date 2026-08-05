class ErrorHandler {
  static String extrairMensagemErro(dynamic erro)  {
    String mensagemcompleta = erro.toString();

    print(mensagemcompleta);

    RegExp regex = RegExp(r"executing statement, (.*?), constraint");
    Match? match = regex.firstMatch(mensagemcompleta);
    
    if (match != null) {
      return match.group(1)!;
    }

    return 'Erro na operação. Tente novamente!';
  }
}