import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/pages/wallet_page.dart';
import 'package:frontend/services/two_factor_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _passwordController = TextEditingController();
  final ConfirmOrderModel o = ConfirmOrderModel(
    startupName: "FinNova",
    tokenSymbol: "FNOVA",
    type: OrderType.buy,
    quantity: 100,
    price: 5,
    userName: "João Pedro",
    userCpf: "400.119.718-94",
    userBalance: 600,
    userTokenBalance: 400,
    userAvgPrice: 4,
  );

  void _showSnack(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<String?> _askForSmsCode() async {
    final smsCodeController = TextEditingController();

    final smsCode = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Digite o código SMS'),
          content: TextField(
            controller: smsCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              labelText: 'Código SMS',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(smsCodeController.text.trim());
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    smsCodeController.dispose();
    return smsCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil'), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: Text('LogOut'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Confirme sua senha:'),
                    content: TextField(
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Confirm'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          try {
                            await activateSMS2FA(
                              _passwordController.text.trim(),
                              _askForSmsCode,
                            );
                            if (!context.mounted) return;
                            _showSnack(
                              'Autenticação por SMS configurada com sucesso.',
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            _showSnack('Falha ao ativar 2FA: $e');
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Text('2FA por SMS'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => WalletPage()));
              },
              child: Text('CARTEIRA'),
            ),
            Text('Pagina de perfil em desenvolvimento'),
          ],
        ),
      ),
    );
  }
}
