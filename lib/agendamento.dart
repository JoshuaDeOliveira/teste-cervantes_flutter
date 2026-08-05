/*Base para os dados dos agendamentos, contendo as informações necessarias do mesmo 
(Id da sala, Qual sala foi selecionada (chave estrangeira) e as datas escolhidas pelo "usuario")
*/

class Agendamento {
  final int? id;
  final int qualSala;
  final String dataInicio;
  final String dataFim;

  Agendamento({
    this.id,
    required this.qualSala,
    required this.dataInicio,
    required this.dataFim,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'qual_sala': qualSala,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
    };
  }

  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id'] as int?,
      qualSala: map['qual_sala'] as int,
      dataInicio: map['data_inicio'] as String,
      dataFim: map['data_fim'] as String,
    );
  }

  @override
  String toString() =>
      'Agendamento(id: $id, sala: $qualSala, inicio: $dataInicio, fim: $dataFim)';
}