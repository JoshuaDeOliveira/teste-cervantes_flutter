//Base para os dados das salas, pegando seu id e seu nome

class Sala {
  final int? id;
  final String nomeSala;

  Sala({
    this.id,
    required this.nomeSala,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_sala': nomeSala,
    };
  }

  factory Sala.fromMap(Map<String, dynamic> map) {
    return Sala(
      id: map['id'] as int?,
      nomeSala: map['nome_sala'] as String,
    );
  }

  @override
  String toString() => 'Sala(id: $id, nome: $nomeSala)';
}