import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controles para ler o que o usuário digita
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Função que faz a chamada para a API
  Future<void> _doLogin() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showAlert("Erro", "Por favor, preencha todos os campos.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.15.13:8080/api/auth/login'), // https://escalas-api-prod.fecservicos.com.br
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cpf': email, // Geralmente a API espera 'username' ou 'email', ajuste conforme o swagger se necessário
          'senha': password,
          'origem': 'MOBILE'
        }),
      );

      // Verificação de Sucesso
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } 
      // Tratamento de Erro baseado no JSON da API
      else {
        String errorMessage = "Ocorreu um erro inesperado."; // Mensagem padrão

        try {
          // Tenta decodificar o JSON de erro
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          
          // Se o campo 'message' existir e não for nulo, usa ele
          if (errorData['message'] != null && errorData['message'].toString().isNotEmpty) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Caso o corpo não seja um JSON válido, mantém a mensagem padrão ou usa o status code
          errorMessage = "Erro no servidor (Status: ${response.statusCode})";
        }

        _showAlert("Falha no Login", errorMessage);
      }
    } catch (e) {
      _showAlert("Erro de Conexão", "Não foi possível conectar ao servidor.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_person, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'FecMobileIA',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _doLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Entrar'),
                      ),
                TextButton(
                  onPressed: () { /* Futuro Cadastro */ },
                  child: const Text('Não tem uma conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}