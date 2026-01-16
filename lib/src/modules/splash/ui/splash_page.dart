import 'package:fec_mobile_ia/src/core/services/session_service.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
    // Aguarda 3 segundos e vai para a tela de login
    //Future.delayed(const Duration(seconds: 3), () {
    //  Navigator.pushReplacementNamed(context, '/login');
    //});
  }

  Future<void> _checkAuth() async {
    // Aguarda 2 segundos para dar tempo de ver a splash
    await Future.delayed(const Duration(seconds: 2));
    
    // Verifica se há token salvo
    bool logged = await SessionService.isLogged();

    if (!mounted) return;

    if (logged) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }    

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'FEC Mobile IA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}