import '../agendamento_dados.dart';
import 'db_service.dart';

// Features para os dados dos Agendamentos

class AgendamentosService {
  
  Future<int> criarAgendamento(Agendamento agendamento) async {
    final db = await DatabaseService.getDatabase();
    return await db.insert('agendamentos', agendamento.toMap());
  }

  Future<List<Agendamento>> listarAgendamentos() async {
    final db = await DatabaseService.getDatabase();
    final resultado = await db.query('agendamentos', orderBy: 'data_inicio ASC');
    return resultado.map((map) => Agendamento.fromMap(map)).toList();
  }

  Future<List<Agendamento>> listarAgendamentosPorSala(int salaId) async {
    final db = await DatabaseService.getDatabase();
    final resultado = await db.query(
      'agendamentos',
      where: 'qual_sala = ?',
      whereArgs: [salaId],
      orderBy: 'data_inicio ASC',
    );
    return resultado.map((map) => Agendamento.fromMap(map)).toList();
  }

  Future<Agendamento?> obterAgendamento(int id) async {
    final db = await DatabaseService.getDatabase();
    final resultado = await db.query('agendamentos', where: 'id = ?', whereArgs: [id]);
    if (resultado.isEmpty) return null;
    return Agendamento.fromMap(resultado.first);
  }

  Future<int> atualizarAgendamento(Agendamento agendamento) async {
    final db = await DatabaseService.getDatabase();
    return await db.update(
      'agendamentos',
      agendamento.toMap(),
      where: 'id = ?',
      whereArgs: [agendamento.id],
    );
  }

  Future<int> deletarAgendamento(int id) async {
    final db = await DatabaseService.getDatabase();
    return await db.delete('agendamentos', where: 'id = ?', whereArgs: [id]);
  }
}