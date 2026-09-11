import 'package:flutter/material.dart';
import 'package:sistema_polpas/pages/clients/widgets/clientes_form_modal.dart';
import 'package:sistema_polpas/pages/clients/widgets/clientes_widgets.dart';
import '../../core/theme/app_colors.dart';
import 'clients_controller.dart';

/// Aba "Clientes".
///
/// Importante: assim como as demais abas, esta página NÃO tem Scaffold,
/// AppHeader nem bottom navigation próprios — o header e a bottom nav
/// continuam definidos só no shell principal
/// (lib/features/bottomNavigationBar/bottom_navigation_page.dart) e não
/// foram alterados aqui.
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
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _openAddClienteModal() {
    showAddClienteModal(context: context, onSave: _controller.addCliente);
  }

  void _openClienteDetailsModal(Cliente cliente) {
    showClienteDetailsModal(
      context: context,
      cliente: cliente,
      onSave: _controller.updateCliente,
      onDelete: _controller.deleteCliente,
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
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // No lugar do card "Base de Clientes" do print original.
                    ClientesSearchBar(onChanged: _controller.updateSearch),
                    const SizedBox(height: 16),
                    // No lugar do quadrado amarelo de fidelidade Premium.
                    ClientesStatsCard(
                      totalAtivos: _controller.totalAtivos,
                      novosEstaSemana: _controller.newThisWeek,
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
                          onTap: () => _openClienteDetailsModal(cliente),
                        ),
                        const SizedBox(height: 14),
                      ],
                  ],
                ),
              ),
              Positioned(
                right: 20,
                bottom: 24,
                child: AddClienteButton(onTap: _openAddClienteModal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
