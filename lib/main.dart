import 'package:flutter/material.dart';
import 'src/modules/splash/ui/splash_page.dart';
import 'src/modules/login/ui/login_page.dart';

void main() {
  runApp(const FecMobileApp());
}

class FecMobileApp extends StatelessWidget {
  const FecMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FecMobileIA',
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
      },
    );
  }
}