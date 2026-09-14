// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

// import 'package:flutter/material.dart';
// import 'package:sistema_polpas/pages/bottom_navigation_bar/bottom_navigation_page.dart';
// import 'core/theme/app_colors.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Graça e Paz',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         scaffoldBackgroundColor: AppColors.background,
//         fontFamily: 'Roboto', // TODO: trocar pela fonte do design system.
//       ),
//       // O BottomNavigationPage é o shell principal do app: ele decide
//       // qual aba (Home, sales, Estoque, Clientes) mostrar.
//       home: const BottomNavigationPage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sistema_polpas/src/rust/api/simple.dart';
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
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
            'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`',
          ),
        ),
      ),
    );
  }
}
