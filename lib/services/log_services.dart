import 'db_service.dart';

class LogService {
  Future<int> countOperacoes(String tabela, String tipo) async {
    final db = await DBService.getDatabase();
    final resultado = await db.query(
      'log_operacoes',
      where: 'nome_tabela = ? AND tipo_operacao = ?',
      whereArgs: [tabela, tipo],
    );
    return resultado.length;
  }
}