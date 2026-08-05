import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'agendamentos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      PRAGMA foreign_keys = ON;

      CREATE TABLE sala (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome_sala TEXT NOT NULL COLLATE NOCASE
      ) STRICT;

      CREATE TABLE agendamentos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          qual_sala INTEGER NOT NULL,
          data_inicio TEXT NOT NULL,
          data_fim TEXT NOT NULL,
          FOREIGN KEY (qual_sala) REFERENCES sala(id)
      ) STRICT;

      CREATE TABLE log_operacoes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome_tabela TEXT NOT NULL,
          tipo_operacao TEXT NOT NULL,
          data_operacao DEFAULT (datetime('now', 'localtime')) NOT NULL,
          CHECK (tipo_operacao IN ('INSERT', 'UPDATE', 'DELETE'))
      );

      CREATE UNIQUE INDEX idx_sala_nome ON sala(nome_sala);
      CREATE INDEX idx_foreignkey_agendamentos ON agendamentos(qual_sala);

      CREATE TRIGGER tr_log_Insert_sala
      AFTER INSERT ON sala
      BEGIN
          INSERT INTO log_operacoes (nome_tabela, tipo_operacao)
          VALUES ('sala', 'INSERT');
      END;

      CREATE TRIGGER tr_log_Delete_sala
      AFTER DELETE ON sala
      BEGIN
          INSERT INTO log_operacoes (nome_tabela, tipo_operacao)
          VALUES ('sala', 'DELETE');
      END;

      CREATE TRIGGER tr_log_Update_sala
      AFTER UPDATE ON sala
      BEGIN
          INSERT INTO log_operacoes (nome_tabela, tipo_operacao)
          VALUES ('sala', 'UPDATE');
      END;

      CREATE TRIGGER tr_log_Insert_agendamento
      AFTER INSERT ON agendamentos
      BEGIN
          INSERT INTO log_operacoes (nome_tabela, tipo_operacao)
          VALUES ('agendamento', 'INSERT');
      END;

      CREATE TRIGGER tr_log_Delete_agendamento
      AFTER DELETE ON agendamentos
      BEGIN
          INSERT INTO log_operacoes (nome_tabela, tipo_operacao)
          VALUES ('agendamento' , 'DELETE');
      END;

      CREATE TRIGGER tr_log_Update_agendamento
      AFTER UPDATE ON agendamentos
      BEGIN
          INSERT INTO log_operacoes (nome_tabela, tipo_operacao)
          VALUES ('agendamento' , 'UPDATE');
      END;

      CREATE TRIGGER tr_excluir_agendamentos
      BEFORE DELETE ON sala
      WHEN EXISTS (
          SELECT id FROM agendamentos
          WHERE qual_sala = OLD.id and
          data_inicio > datetime('now', 'localtime')
      )
      BEGIN 
          SELECT RAISE(ABORT, 'Não é possivel apagar uma sala agendada! Por favor, revise os agendamentos programados');
      END;

      CREATE TRIGGER tr_bloquearigualdade_insert
      BEFORE INSERT ON agendamentos
      WHEN EXISTS (
          SELECT id FROM agendamentos
          WHERE qual_sala = NEW.qual_sala and data_inicio < NEW.data_fim 
          and data_fim > NEW.data_inicio
      )
      BEGIN 
          SELECT RAISE(ABORT, 'A data escolhida ja esta agendada para a sala! Por favor, escolha uma nova data ou uma nova sala');
      END;

      CREATE TRIGGER tr_bloquearigualdade_update
      BEFORE UPDATE ON agendamentos
      WHEN EXISTS (
          SELECT id from agendamentos
          WHERE id != NEW.id and qual_sala = NEW.qual_sala and
          data_inicio < NEW.data_fim and data_fim > NEW.data_inicio
      )
      BEGIN
          SELECT RAISE(ABORT, 'A data escolhida ja esta agendada para a sala! Por favor, escolha uma nova data ou uma nova sala');
      END;

      CREATE TRIGGER tr_bloquear_nome_duplicado_insert
      BEFORE INSERT ON sala
      WHEN EXISTS (
          SELECT id FROM sala
          WHERE REPLACE(TRIM(LOWER(NEW.nome_sala)), ' ', '') = 
          REPLACE(TRIM(LOWER(nome_sala)), ' ', '')
      )
      BEGIN
          SELECT RAISE(ABORT, 'Esse nome ja esta em uso! Por favor, verifique as salas existentes');
      END;

      CREATE TRIGGER tr_bloquear_nome_duplicado_update
      BEFORE UPDATE ON sala
      WHEN EXISTS (
          SELECT id FROM sala
          WHERE REPLACE(TRIM(LOWER(NEW.nome_sala)), ' ', '') =
          REPLACE(TRIM(LOWER(nome_sala)), ' ', '') and NEW.id != id 
      )
      BEGIN
          SELECT RAISE(ABORT, 'Esse nome ja esta em uso! Por favor, verifique as salas existentes');
      END;

      CREATE TRIGGER tr_data_passado_insert
      BEFORE INSERT ON agendamentos
      WHEN NEW.data_inicio < CURRENT_TIMESTAMP
      BEGIN
          SELECT RAISE(ABORT, 'Não é possivel agendar uma sala para o passado');
      END;

      CREATE TRIGGER tr_data_passado_update
      BEFORE UPDATE ON agendamentos
      WHEN NEW.data_inicio < CURRENT_TIMESTAMP
      BEGIN
          SELECT RAISE(ABORT, 'Não é possivel atualizar o horario para o passado');
      END;

      CREATE TRIGGER tr_datas_discrepantes_insert
      BEFORE INSERT ON agendamentos
      WHEN NEW.data_fim < NEW.data_inicio
      BEGIN
          SELECT RAISE(ABORT, 'Verifique novamente as datas inseridas!');
      END;

      CREATE TRIGGER tr_datas_discrepantes_update
      BEFORE UPDATE ON agendamentos
      WHEN  NEW.data_inicio > NEW.data_fim
      BEGIN
          SELECT RAISE(ABORT, 'Verifique novamente as datas escolhidas para atualizar o agendamento!');
      END;

      CREATE TRIGGER tr_nome_vazio_insert
      BEFORE INSERT ON sala
      WHEN TRIM(NEW.nome_sala) = ''
      BEGIN 
          SELECT RAISE(ABORT, 'Por favor digite um nome para cadastrar a sala!');
      END;

      CREATE TRIGGER tr_nome_vazio_update
      BEFORE UPDATE ON sala
      WHEN TRIM(NEW.nome_sala) = ''
      BEGIN
          SELECT RAISE(ABORT, 'Por favor digite um nome para atualizar o cadastro da sala');
      END;

      CREATE TRIGGER tr_datas_vazias_insert
      BEFORE INSERT ON agendamentos
      WHEN TRIM(NEW.data_fim) = '' OR TRIM(NEW.data_inicio) = ''
      BEGIN
          SELECT RAISE(ABORT, 'Por favor digite a data em que deseja reservar o agendamento');
      END; 

      CREATE TRIGGER tr_datas_vazias_update
      BEFORE UPDATE ON agendamentos
      WHEN TRIM(NEW.data_fim) = '' OR TRIM(NEW.data_inicio) = ''
      BEGIN 
          SELECT RAISE(ABORT, 'Por favor digite as datas antes de atualizar o agendamento');
      END;

      CREATE TRIGGER tr_qual_sala_insert
      BEFORE INSERT ON agendamentos
      WHEN NEW.qual_sala IS NULL
      BEGIN
          SELECT RAISE(ABORT, 'Por favor escolha a sala em que quer registrar!');
      END;

      CREATE TRIGGER tr_qual_sala_update
      BEFORE UPDATE ON agendamentos
      WHEN NEW.qual_sala IS NULL
      BEGIN
          SELECT RAISE(ABORT, 'Por favor escolha a sala que deseja atualizar o cadastro');
      END;
    ''');
  }
}