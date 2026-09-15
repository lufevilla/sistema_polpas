import 'package:flutter/material.dart';
import 'package:sistema_polpas/pages/clients/widgets/clientes_form_modal.dart';
import 'package:sistema_polpas/pages/clients/widgets/clientes_widgets.dart';
import '../../core/theme/app_colors.dart';
import 'clients_controller.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClientesController _controller = ClientesController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_aoControladorMudar);
    _controller.carregarClientes();
  }

  @override
  void dispose() {
    _controller.removeListener(_aoControladorMudar);
    super.dispose();
  }

  void _aoControladorMudar() => setState(() {});

  void _abrirModalNovoCliente() {
    mostrarModalNovoCliente(
      context: context,
      aoSalvar: _controller.adicionarCliente,
    );
  }

  void _abrirModalDetalhesCliente(ClienteLocal cliente) {
    mostrarModalDetalhesCliente(
      context: context,
      cliente: cliente,
      aoSalvar: _controller.atualizarCliente,
      aoExcluir: _controller.excluirCliente,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientes = _controller.clientes;

    return Scaffold(
      appBar: AppBar(
        title: Text("Clientes"),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              if (_controller.carregando)
                const Center(child: CircularProgressIndicator())
              else if (_controller.erro.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Erro ao carregar clientes',
                          style: TextStyle(color: AppColors.danger),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _controller.erro,
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _controller.carregarClientes,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClientesSearchBar(onChanged: _controller.atualizarBusca),
                      const SizedBox(height: 16),
                      ClientesStatsCard(
                        totalAtivos: _controller.totalAtivos,
                        novosEstaSemana: _controller.novosEstaSemana,
                      ),
                      const SizedBox(height: 20),
                      if (clientes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              'Nenhum cliente encontrado.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        )
                      else
                        for (final cliente in clientes) ...[
                          ClienteListTile(
                            cliente: cliente,
                            aoTocar: () => _abrirModalDetalhesCliente(cliente),
                          ),
                          const SizedBox(height: 14),
                        ],
                    ],
                  ),
                ),
              Positioned(
                right: 20,
                bottom: 24,
                child: BotaoAdicionarCliente(aoTocar: _abrirModalNovoCliente),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
