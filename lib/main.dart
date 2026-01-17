import 'package:fec_mobile_ia/src/modules/escalas/ui/escalas_page.dart';
import 'package:fec_mobile_ia/src/modules/registro/ui/registro_page.dart';
import 'package:flutter/material.dart';
import 'src/modules/splash/ui/splash_page.dart';
import 'src/modules/login/ui/login_page.dart';
import 'src/modules/home/ui/home_page.dart';
import 'src/modules/register/ui/register_page.dart'; // Adicione o import

void main() {
  runApp(const FecMobileApp());
}

class FecMobileApp extends StatelessWidget {
  const FecMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FEC Serviços',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Definimos a Splash como tela inicial
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(), // Nova rota
        // No Map de routes:
        '/register': (context) => const RegisterPage(),
        '/escalas': (context) => const EscalasPage(),
        '/registro': (context) => const RegistroPage(),
      },
    );
  }
}