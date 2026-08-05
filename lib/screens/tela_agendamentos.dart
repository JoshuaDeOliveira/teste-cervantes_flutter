import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/agendamento_dados.dart';
import '../data/sala_dados.dart';
import '../services/salas_service.dart';
import '../services/agendamento_services.dart';
import '../helpers/error_handler.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({Key? key}) : super(key: key);

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  late AgendamentosService _agendamentosService;
  late SalasService _salasService;
  List<Agendamento> _agendamentos = [];
  List<Sala> _salas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _agendamentosService = AgendamentosService();
    _salasService = SalasService();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final agendamentos = await _agendamentosService.listarAgendamentos();
      final salas = await _salasService.listarSalas();
      setState(() {
        _agendamentos = agendamentos;
        _salas = salas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarErro(ErrorHandler.extrairMensagemErro(e));
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _obterNomeSala(int salaId) {
    try {
      return _salas.firstWhere((s) => s.id == salaId).nomeSala;
    } catch (e) {
      return 'Sala Desconhecida';
    }
  }

  void _abrirDialogCriar() {
    int? salaId;
    DateTime? dataInicio;
    DateTime? dataFim;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Criar Agendamento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown de salas
                DropdownButtonFormField<int>(
                  value: salaId,
                  hint: const Text('Selecione uma sala'),
                  items: _salas
                      .map((sala) => DropdownMenuItem(
                            value: sala.id,
                            child: Text(sala.nomeSala),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => salaId = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sala',
                  ),
                ),
                const SizedBox(height: 16),

                // Data e Hora Início
                ListTile(
                  title: const Text('Data/Hora Início'),
                  subtitle: Text(dataInicio == null
                      ? 'Não selecionado'
                      : DateFormat('dd/MM/yyyy HH:mm').format(dataInicio!)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          dataInicio = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Data e Hora Fim
                ListTile(
                  title: const Text('Data/Hora Fim'),
                  subtitle: Text(dataFim == null
                      ? 'Não selecionado'
                      : DateFormat('dd/MM/yyyy HH:mm').format(dataFim!)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dataInicio ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          dataFim = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final agendamento = Agendamento(
                    qualSala: salaId!,
                    dataInicio: dataInicio!.toIso8601String(),
                    dataFim: dataFim!.toIso8601String(),
                  );
                  await _agendamentosService.criarAgendamento(agendamento);
                  Navigator.pop(context);
                  _carregarDados();
                  _mostrarSucesso('Agendamento criado com sucesso!');
                } catch (e) {
                  _mostrarErro(ErrorHandler.extrairMensagemErro(e));
                }
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletarAgendamento(Agendamento agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Deseja deletar o agendamento de ${_obterNomeSala(agendamento.qualSala)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _agendamentosService.deletarAgendamento(agendamento.id!);
                Navigator.pop(context);
                _carregarDados();
                _mostrarSucesso('Agendamento deletado com sucesso!');
              } catch (e) {
                _mostrarErro(ErrorHandler.extrairMensagemErro(e));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agendamentos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Nenhum agendamento'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _abrirDialogCriar,
                        child: const Text('Criar Agendamento'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _agendamentos.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final agendamento = _agendamentos[index];
                    final dataInicio =
                        DateTime.parse(agendamento.dataInicio);
                    final dataFim = DateTime.parse(agendamento.dataFim);

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.event,
                            color: Colors.blue.shade400),
                        title: Text(_obterNomeSala(agendamento.qualSala)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Início: ${DateFormat('dd/MM/yyyy HH:mm').format(dataInicio)}',
                            ),
                            Text(
                              'Fim: ${DateFormat('dd/MM/yyyy HH:mm').format(dataFim)}',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletarAgendamento(agendamento),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogCriar,
        child: const Icon(Icons.add),
      ),
    );
  }
}