import 'package:flutter/material.dart';
import 'package:sistema_polpas/pages/sales/widgets/sales_form_modal.dart';
import 'package:sistema_polpas/pages/sales/widgets/sales_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/add_floating_button.dart';
import 'sales_controller.dart';

/// Aba "sales" (Histórico de sales).
///
/// Importante: assim como as demais abas, esta página NÃO tem Scaffold,
/// AppHeader nem bottom navigation próprios — o header e a bottom nav
/// continuam definidos só no shell principal
/// (lib/features/bottomNavigationBar/bottom_navigation_page.dart) e não
/// foram alterados aqui.
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final SalesController _controller = SalesController();

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

  void _openAddVendaModal() {
    showAddVendaModal(
      context: context,
      clientesDisponiveis: _controller.clientesDisponiveis,
      onSave: _controller.addPedido,
    );
  }

  void _openVendaDetailsModal(Pedido pedido) {
    showVendaDetailsModal(
      context: context,
      pedido: pedido,
      itens: _controller.itensDoPedido(pedido.idPedido),
      clientesDisponiveis: _controller.clientesDisponiveis,
      onSave: _controller.updatePedido,
      onDelete: _controller.deletePedido,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = _controller.pedidos;

    return Scaffold(
      appBar: AppBar(
        title: Text("Vendas"),
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
                    SalesSearchBar(
                      onChanged: _controller.updateSearch,
                      onFilterTap: () {
                        // TODO: implementar filtros reais (status, período, etc).
                      },
                    ),
                    const SizedBox(height: 20),
                    if (pedidos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'Nenhuma venda encontrada.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    else
                      for (final pedido in pedidos) ...[
                        VendaListTile(
                          pedido: pedido,
                          nomeCliente: _controller.nomeCliente(
                            pedido.clienteId,
                          ),
                          itens: _controller.itensDoPedido(pedido.idPedido),
                          onTap: () => _openVendaDetailsModal(pedido),
                          onEmitirNotaFiscal: () =>
                              _controller.emitirNotaFiscal(pedido.idPedido),
                        ),
                        const SizedBox(height: 14),
                      ],
                  ],
                ),
              ),
              Positioned(
                right: 20,
                bottom: 24,
                child: AddFloatingButton(onTap: _openAddVendaModal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
