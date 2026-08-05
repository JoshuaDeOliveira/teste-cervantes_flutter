import 'package:flutter/material.dart';
import '../data/log_dados.dart';
import '../services/log_services.dart';
import '../helpers/error_handler.dart';

//Configuração para a tela do log

class TelaLog extends StatefulWidget {
  const TelaLog({Key? key}) : super(key: key);
 
  @override
  State<TelaLog> createState() => _TelaLogState();
}
 
class _TelaLogState extends State<TelaLog> {
  late LogService _logService;
  List<LogOperacao> _logs = [];
  bool _isLoading = true;
 
  @override
  void initState() {
    super.initState();
    _logService = LogService();
    _carregarLogs();
  }
 
  Future<void> _carregarLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _logService.listarLog();
      setState(() {
        _logs = logs;
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
 
  Color _obterCorOperacao(String tipo) {
    switch (tipo) {
      case 'INSERT':
        return Colors.green;
      case 'UPDATE':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Nenhum registro no log'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _logs.length + 1,
                  itemBuilder: (context, index) {
                    // Cabeçalho
                    if (index == 0) {
                      return Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'ID',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Tabela',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Operação',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Data/Hora',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
 
                    // Linhas
                    final log = _logs[index - 1];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(log.id.toString()),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(log.nomeTabela),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _obterCorOperacao(log.tipoOperacao),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                log.tipoOperacao,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 3,
                            child: Text(log.dataOperacao),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _carregarLogs,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
