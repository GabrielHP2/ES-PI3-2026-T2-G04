import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model_nota.dart'; 

class TransactionConfirmationPage extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionConfirmationPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

    const Color primaryBlue = Color(0xFF5C6BC0); 
    const Color successGreen = Color(0xFF19B2A3);
    const Color backgroundGray = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('CONFIRMAÇÃO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // nao volta pelo botao do celular
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline, color: successGreen, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Operação Realizada com Sucesso!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: successGreen),
                  ),
                  const SizedBox(height: 30),
                  
                  // Card da operação
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
    
                       // !! NOMES GENERICOS, QUANDO FOR INTEGRAR FAZER ALTERE CASO FOR DIFERENTE !!!!!!!!!
                        _buildInfoRow('ID da Transação', transaction.id, isCode: true),
                        const Divider(),
                        _buildInfoRow('Startup', transaction.startupName),
                        _buildInfoRow('Ativo', transaction.ticker),
                        _buildInfoRow('Tipo', transaction.type),
                        _buildInfoRow('Quantidade', '${transaction.quantity} tokens'),
                        _buildInfoRow('Preço Unitário', currencyFormat.format(transaction.unitPrice)),
                        const Divider(),
                        _buildInfoRow(
                          'TOTAL SIMULADO', 
                          currencyFormat.format(transaction.totalValue),
                          isBold: true,
                          color: primaryBlue
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Dados do Usuário
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Investidor', transaction.investorName),  // construtores das infromações do investir no momento da nota
                        _buildInfoRow('CPF', transaction.investorCpf),
                        _buildInfoRow('Data/Hora', dateFormat.format(transaction.timestamp)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão de Retorno
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // @ Panza, o pop é para retorno para dashboard depois de exibir a nota fiscal na tela, como nao acabo fica o gap
                  
                  Navigator.pop(context, true); 
                  
                  // ----------------------------------------------
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'CONCLUIR E VOLTAR',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color, bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: isBold ? 15 : 13,
                color: color ?? Colors.black87,
                fontFamily: isCode ? 'Courier' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}