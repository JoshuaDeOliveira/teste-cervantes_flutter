import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/tela_salas.dart';

void main() {
  databaseFactory = databaseFactoryFfi;
  runApp(const AppAgendamentos());
}

class AppAgendamentos extends StatelessWidget{
  const AppAgendamentos({Key? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agendamento de Salas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SalasScreen(),
    );
  }
}
