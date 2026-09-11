import 'package:flutter/material.dart';
import 'package:sistema_polpas/pages/app_header/app_header.dart';
import 'package:sistema_polpas/pages/app_header/app_header_controller.dart';
import 'package:sistema_polpas/pages/reports/reports_page.dart';
import 'package:sistema_polpas/pages/home/home_page.dart';
import 'package:sistema_polpas/pages/stock/stock_page.dart';
import 'bottom_navigation_bar.dart';

/// Página/shell principal do app.
///
/// É este widget que deve ser chamado direto no `main.dart` (ex: como
/// `home:` do MaterialApp). Ele é o dono do Scaffold, do AppHeader fixo
/// no topo (equivalente a uma AppBar customizada, visível em todas as
/// abas) e da bottom navigation bar, e troca o conteúdo exibido
/// conforme a aba selecionada — Início (Home), sales, Estoque e
/// Clientes.
class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  final AppHeaderController _headerController = AppHeaderController();
  int _currentIndex = 0;

  // Ordem tem que bater com os itens definidos em
  // BottomNavigationBarWidget (Início, sales, Estoque, Clientes).
  static final List<Widget> _pages = [
    const HomePage(),
    const ReportsPage(),
    const StockPage(),
  ];

  void _onTabTapped(int index) {
    // TODO: disparar analytics / lógica extra de navegação se necessário.
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header fixo, igual a uma AppBar: fica visível em todas as
          // abas, independente de qual página está selecionada.
          AppHeader(storeInfo: _headerController.storeInfo),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
