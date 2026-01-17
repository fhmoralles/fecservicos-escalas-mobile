import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Máscaras (Usaremos .getUnmaskedText() para enviar apenas números à API)
  final _cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _phoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  // Selecionáveis
  String? _selectedPixKey;
  final List<String> _pixOptions = ['CPF', 'PHONE', 'EMAIL'];

  String? _selectedRole;
  final List<String> _roleOptions = ['REPOSITOR', 'OPERADOR DE CAIXA', 'AUXILIAR DE DEPOSITO', 'EMPACOTADOR', 'OUTROS'];

  bool _showPassword = false;

  // Função para limpar e validar e-mail
  bool _isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  // --- LÓGICA DE INTEGRAÇÃO COM A API ---
  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.15.4:8080/api/auth/cadastrar'), // https://escalas-api-prod.fecservicos.com.br
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": _nameController.text,
          "cpf": _cpfFormatter.getUnmaskedText(), // Envia apenas números
          "email": _emailController.text,
          "telefone": _phoneFormatter.getUnmaskedText(), // Envia apenas números
          "pix": _selectedPixKey,
          "senha": _passwordController.text,
          "funcao": _selectedRole,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        
        // Sucesso: Alerta e volta para Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso! Faça seu login.'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Erro: Trata o JSON da API conforme requisito
        String errorMessage = "Erro ao realizar cadastro.";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) errorMessage = errorData['message'];
        } catch (_) {}
        _showAlert("Falha no Cadastro", errorMessage);
      }
    } catch (e) {
      _showAlert("Erro", "Falha de conexão com o servidor.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cadastro'), leading: const SizedBox()), // Remove seta padrão para usar botão customizado
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo*', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: TextEditingController(text: _cpfFormatter.getMaskedText()),
                inputFormatters: [_cpfFormatter],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'CPF*', border: OutlineInputBorder()),
                validator: (v) => _cpfFormatter.getUnmaskedText().length < 11 ? 'CPF incompleto' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail*', border: OutlineInputBorder()),
                validator: (v) => !_isValidEmail(v!) ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                inputFormatters: [_phoneFormatter],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Celular*', border: OutlineInputBorder()),
                validator: (v) => _phoneFormatter.getUnmaskedText().length < 11 ? 'Celular incompleto' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Chave Pix*', border: OutlineInputBorder()),
                value: _selectedPixKey,
                items: _pixOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedPixKey = v),
                validator: (v) => v == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Senha*',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (v) => v!.length < 6 ? 'Mínimo 6 dígitos' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Senha*', border: OutlineInputBorder()),
                validator: (v) => v != _passwordController.text ? 'As senhas não coincidem' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Função*', border: OutlineInputBorder()),
                value: _selectedRole,
                items: _roleOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
                validator: (v) => v == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 30),

              // --- BOTÕES ---
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _doRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Cadastrar'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Voltar'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}