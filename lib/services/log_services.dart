import '../data/log_dados.dart';
import 'db_service.dart';

//Mostrar os dados do log de operações

class LogService {
  Future<List<LogOperacao>> listarLog() async {
    final db = await DBService.getDatabase();
    final resultado = await db.query(
      'log_operacoes',
      orderBy: 'data_operacao DESC',
    );
    return resultado.map((map) => LogOperacao.fromMap(map)).toList();
  }

  Future<List<LogOperacao>> listarLogPorTabela(String tabela) async {
    final db = await DBService.getDatabase();
    final resultado = await db.query(
      'log_operacoes',
      where: 'nome_tabela = ?',
      whereArgs: [tabela],
      orderBy: 'data_operacao DESC',
    );
    return resultado.map((map) => LogOperacao.fromMap(map)).toList();
  }
}