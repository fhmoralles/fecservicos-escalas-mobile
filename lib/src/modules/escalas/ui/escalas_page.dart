import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/services/session_service.dart';

class EscalasPage extends StatefulWidget {
  const EscalasPage({super.key});

  @override
  State<EscalasPage> createState() => _EscalasPageState();
}

class _EscalasPageState extends State<EscalasPage> {
  bool _isLoading = false;
  List<dynamic> _dadosEscala = [];

  // Lógica para buscar as escalas
  Future<void> _atualizarEscalas() async {
    setState(() => _isLoading = true);

    try {
      final String? token = await SessionService.getToken();

      final response = await http.get(
        Uri.parse('http://192.168.15.4:8080/api/mobile/escala/prestador'), // https://escalas-api-prod.fecservicos.com.br
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          setState(() {
            _dadosEscala = jsonDecode(response.body);
          });
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escalas atualizadas com sucesso!'), backgroundColor: Colors.green),
        );
      } else {
        String errorMessage = "Erro ao carregar escalas.";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) errorMessage = errorData['message'];
        } catch (_) {}
        _showAlert("Atenção", errorMessage);
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
      appBar: AppBar(title: const Text('Minhas Escalas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _atualizarEscalas,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync),
                label: const Text('Atualizar'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _dadosEscala.isEmpty
                  ? const Center(child: Text("Nenhum dado disponível. Clique em Atualizar."))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Data')),
                            DataColumn(label: Text('Loja/Local')),
                            DataColumn(label: Text('Horário')),
                            DataColumn(label: Text('Registro')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: _dadosEscala.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item['data']?.toString() ?? '-')),
                              DataCell(Text(item['loja']?.toString() ?? '-')),
                              DataCell(Text(item['horario']?.toString() ?? '-')),
                              DataCell(Text(item['registro']?.toString() ?? '-')),
                              DataCell(Text(item['status']?.toString() ?? '-')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}