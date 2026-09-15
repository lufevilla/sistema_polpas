import 'package:flutter/material.dart';

// Importações do projeto
import 'package:sistema_polpas/core/theme/app_colors.dart';
import 'package:sistema_polpas/pages/bottom_navigation_bar/bottom_navigation_page.dart';
import 'package:sistema_polpas/src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graça e Paz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.headerStart,
          primary: AppColors.headerStart,
          secondary: AppColors.gold,
          surface: AppColors.cardBackground,
          error: AppColors.danger,
        ),
        // Exemplo de como aplicar cores globais de texto ou borda:
        dividerColor: AppColors.border,
        fontFamily: 'Roboto',
      ),
      home: const BottomNavigationPage(),
    );
  }
}