import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home_controller.dart';
import 'widgets/home_widgets.dart';

/// Aba "Início" do app.
///
/// Importante: esta página NÃO tem Scaffold, AppHeader nem bottom
/// navigation próprios — ela é usada como o conteúdo de uma das abas
/// dentro do shell principal
/// (ver lib/features/bottomNavigationBar/bottom_navigation_page.dart),
/// que já cuida do header fixo no topo.
///
/// O conteúdo é rolável (SingleChildScrollView) para acomodar a seção
/// de stock + o link "Ver stock completo" no final.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NovoPedidoCard(onTap: _controller.onNovoPedidoTap),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionCard(
                        icon: Icons.people_alt_outlined,
                        label: 'Clientes',
                        onTap: () => _controller.onClientesTap(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: QuickActionCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Vendas',
                        onTap: () => _controller.onsalesTap(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                NotasFiscaisTile(onTap: _controller.onNotasFiscaisTap),
                const SizedBox(height: 20),
                StockHighlightSection(
                  items: _controller.highlightedStock,
                  onVerEstoqueCompleto: _controller.onVerEstoqueCompletoTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
