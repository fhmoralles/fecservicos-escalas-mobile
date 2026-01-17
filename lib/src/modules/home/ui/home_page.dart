import 'package:flutter/material.dart';
import '../../../core/services/session_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FecMobileIA'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // Aqui adicionamos o Menu Hambúrguer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Cabeçalho do Menu
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blueAccent),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bem-vindo!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            
            // Item: Início (opcional, apenas para preencher o menu)
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
              },
            ),

            const Divider(), // Linha divisória

            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Escalas'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                Navigator.pushNamed(context, '/escalas'); // Vai para a página de escalas
              },
            ),
            
            const Divider(), // Linha divisória
            
            // Item: Sair (Botão de Logout)
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                // 1. Limpa o token salvo
                await SessionService.logout();

                // 2. Redireciona para o login e limpa toda a pilha de telas
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false, // Impede que o usuário volte para a Home ao apertar "Voltar"
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Você está logado!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Abra o menu hambúrguer no canto superior esquerdo para sair.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}