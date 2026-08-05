class LogOperacao {
  final int? id;
  final String nomeTabela;
  final String tipoOperacao;
  final String dataOperacao;

  LogOperacao({
    this.id,
    required this.nomeTabela,
    required this.tipoOperacao,
    required this.dataOperacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_tabela': nomeTabela,
      'tipo_operacao': tipoOperacao,
      'data_operacao': dataOperacao,
    };
  }

  factory LogOperacao.fromMap(Map<String, dynamic> map) {
    return LogOperacao(
      id: map['id'] as int?,
      nomeTabela: map['nome_tabela'] as String,
      tipoOperacao: map['tipo_operacao'] as String,
      dataOperacao: map['data_operacao'] as String,
    );
  }

  @override
  String toString() =>
      'LogOperacao(id: $id, tabela: $nomeTabela, tipo: $tipoOperacao, data: $dataOperacao)';
}