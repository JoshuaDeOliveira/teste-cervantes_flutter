import '../sala_dados.dart';
import 'db_service.dart';

/*Features para os dados das Salas*/

class SalasService {
  Future<int> criarSala(Sala NovaSala) async {
    final db = await DatabaseService.getDatabase();
    return await db.insert('sala', NovaSala.toMap());
  }

  Future<List<Sala>> listarSalas() async {
    final db = await DatabaseService.getDatabase();
    final resultado = await db.query('sala', orderBy: 'nome_sala ASC');
    return resultado.map((map) => Sala.fromMap(map)).toList();
  }


  Future<Sala?> obterSala(int idsala) async {
    final db = await DatabaseService.getDatabase();
    final resultado = await db.query('sala', where: 'id = ?', whereArgs: [idsala]);
    if (resultado.isEmpty) return null;
    return Sala.fromMap(resultado.first);
  }


  Future<int> atualizarSala(Sala UpdateSala) async {
    final db = await DatabaseService.getDatabase();
    return await db.update(
      'sala',
      UpdateSala.toMap(),
      where: 'id = ?',
      whereArgs: [UpdateSala.id],
    );
  }

  Future<int> deletarSala(int id) async {
    final db = await DatabaseService.getDatabase();
    return await db.delete('sala', where: 'id = ?', whereArgs: [id]);
  }

}
