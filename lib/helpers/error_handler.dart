//Uma pequena feature que possibilita mostrar a mensagem de erro personalizado dos triggers do sqlite

class ErrorHandler {
  static String extrairMensagemErro(dynamic erro)  {
    String mensagemcompleta = erro.toString();

    RegExp regex = RegExp(r"executing statement, (.*?), constraint");
    Match? match = regex.firstMatch(mensagemcompleta);
    
    if (match != null) {
      return match.group(1)!;
    }

    return 'Erro na operação. Tente novamente!';
  }
}