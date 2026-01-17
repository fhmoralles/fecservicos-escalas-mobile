import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/services/session_service.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  bool _isProcessing = false;
  MobileScannerController cameraController = MobileScannerController();

  // Lógica para processar o QRCode e chamar a API
  Future<void> _processarRegistro(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // 1. Parse do JSON do QRCode
      final Map<String, dynamic> data = jsonDecode(code);
      final String escala = data['escala'].toString();
      final String tipo = data['tipo'].toString();

      // 2. Recupera o Token
      final String? token = await SessionService.getToken();

      // 3. Requisição PUT com parâmetros na URL
      final response = await http.put(
        Uri.parse('http://192.168.15.4:8080/api/mobile/escala/registrar/$escala/$tipo'), // https://escalas-api-prod.fecservicos.com.br
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro realizado com sucesso!'), backgroundColor: Colors.green),
        );
        // Retorna para a página de Escalas
        Navigator.pushReplacementNamed(context, '/escalas');
      } else {
        String message = "Erro no registro.";
        try {
          final errorBody = jsonDecode(response.body);
          message = errorBody['message'] ?? message;
        } catch (_) {}
        _showError(message);
      }
    } catch (e) {
      _showError("QRCode inválido ou erro de conexão.");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Falha no Registro"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ler QRCode Registro')),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processarRegistro(barcode.rawValue!);
                }
              }
            },
          ),
          // Overlay para ajudar o usuário a centralizar
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        ],
      ),
    );
  }
}