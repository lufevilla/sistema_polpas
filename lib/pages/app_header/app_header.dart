import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_header_controller.dart';

/// Cabeçalho fixo do app (equivalente a uma AppBar customizada), com fundo
/// em degradê e borda curva na parte inferior. Fica visível em todas as
/// abas (Início, sales, Estoque, Clientes), definido uma única vez no
/// shell principal (ver bottomNavigationBar/bottom_navigation_page.dart).
///
/// Conforme solicitado, o menu hambúrguer e a foto de perfil foram
/// desconsiderados nesta versão.
class AppHeader extends StatelessWidget {
  final StoreInfo storeInfo;

  const AppHeader({super.key, required this.storeInfo});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderBottomCurveClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: 64,
          bottom: 48,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.headerStart, AppColors.headerEnd],
          ),
        ),
        child: Column(
          children: [
            Text(
              // TODO: nome do negócio (StoreInfo.name)
              storeInfo.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              // TODO: subtítulo/categoria do negócio (StoreInfo.subtitle)
              storeInfo.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 28)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + 24,
        size.width,
        size.height - 28,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
