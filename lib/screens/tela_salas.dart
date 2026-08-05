import 'package:flutter/material.dart';
import '../data/sala_dados.dart';
import '../services/salas_service.dart';
import '../helpers/error_handler.dart';

//Configurações para a tela da sala

class SalasScreen extends StatefulWidget {
  const SalasScreen({Key? key}) : super(key: key);

  @override
  State<SalasScreen> createState() => _SalasScreenState();
}

class _SalasScreenState extends State<SalasScreen> {
  late SalasService _salasService;
  List<Sala> _salas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _salasService = SalasService();
    _carregarSalas();
  }

  Future<void> _carregarSalas() async {
    setState(() => _isLoading = true);
    try {
      final salas = await _salasService.listarSalas();
      setState(() {
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

  void _abrirDialogCriar() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Nova Sala'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nome da sala',
            border: OutlineInputBorder(),
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
                final novaSala = Sala(nomeSala: controller.text.trim());
                await _salasService.criarSala(novaSala);
                Navigator.pop(context);
                _carregarSalas();
                _mostrarSucesso('Sala criada com sucesso!');
              } catch (e) {
                _mostrarErro(ErrorHandler.extrairMensagemErro(e));
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _abrirDialogEditar(Sala sala) {
    final controller = TextEditingController(text: sala.nomeSala);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Sala'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nome da sala',
            border: OutlineInputBorder(),
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
                final salaAtualizada = Sala(
                  id: sala.id,
                  nomeSala: controller.text.trim(),
                );
                await _salasService.atualizarSala(salaAtualizada);
                Navigator.pop(context);
                _carregarSalas();
                _mostrarSucesso('Sala atualizada!');
              } catch (e) {
                _mostrarErro(ErrorHandler.extrairMensagemErro(e));
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _deletarSala(Sala sala) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: Text('Deseja deletar a sala "${sala.nomeSala}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _salasService.deletarSala(sala.id!);
                Navigator.pop(context);
                _carregarSalas();
                _mostrarSucesso('Sala deletada!');
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
          : _salas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.meeting_room, size: 64, color: Colors.black),
                      const SizedBox(height: 16),
                      const Text('Nenhuma sala cadastrada no sistema!'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _abrirDialogCriar,
                        child: const Text('Criar Primeira Sala'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _salas.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final sala = _salas[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.meeting_room,
                            color: Colors.blue.shade400),
                        title: Text(sala.nomeSala),
                        subtitle: Text('ID: ${sala.id}'),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Editar'),
                              onTap: () =>
                                  Future.delayed(Duration.zero,
                                      () => _abrirDialogEditar(sala)),
                            ),
                            PopupMenuItem(
                              child: const Text('Deletar',
                                  style: TextStyle(color: Colors.red)),
                              onTap: () =>
                                  Future.delayed(Duration.zero,
                                      () => _deletarSala(sala)),
                            ),
                          ],
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