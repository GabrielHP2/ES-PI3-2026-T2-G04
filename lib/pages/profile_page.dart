// Gabriel Hespanholeto Maziero 25004669
import 'package:firebase_auth/firebase_auth.dart'; // logout
import 'package:flutter/material.dart'; 
import 'package:frontend/pages/wallet_page.dart'; // navegação ate a carteira
import 'package:frontend/services/two_factor_services.dart'; // 2fa

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Estado da página
  bool _isEmailAuthEnabled = true; // controlador do opção ligada e desligada do email
  bool _isSmsAuthEnabled = false; // do 2fa
  
  // Leitor campo da senha
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }


  // Notificação de erro ou sucesso em baixo da tela
  void _showSnack(String message, {Color? backgroundColor}) {
    if (!mounted) return; // sem aviso ao fechar a tela
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar(); // Limpa avisos anteriores
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor ?? const Color(0xFF5759E0)),
    );
  }

  // validação 6 numeros do sms
  Future<String?> _askForSmsCode() async {
    final smsCodeController = TextEditingController(); // Controlador do código
    
    //  pausa a tela e exibe o pop-up
    final smsCode = await showDialog<String>(
      context: context,
      barrierDismissible: false, // Impede de fechar clicando fora da caixa
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Digite o código SMS', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: smsCodeController,
            keyboardType: TextInputType.number, // Abre o teclado numérico
            maxLength: 6, // max 6 digitos
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              labelText: 'Código SMS',
              counterText: '', // esconde o contador de caracteres até o  sexto
            ),
          ),
          actions: [
            // Botão Cancelar
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            // Botão Confirmar
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(smsCodeController.text.trim()),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff7AE058)),
              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    smsCodeController.dispose(); // Libera memória
    return smsCode; // retorno do numero digitado
  }


    // FUNCAO de inicio do fluxo de segurança SE o 2FA for ativado (!!!!)
  void _iniciarFluxo2FA() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirme sua senha:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _passwordController,
          obscureText: true, // Esconde a senha 
          decoration: const InputDecoration(hintText: 'Sua senha do MesclaInvest'),
        ),
        actions: [
          // se cancelar o switch volta
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _isSmsAuthEnabled = false); 
            },
          ),
          // Se sucesso inici o contato com o back
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5759E0)),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(context).pop(); 
              try {
                // Tenta ativar via Backend
                await activateSMS2FA(
                  _passwordController.text.trim(),
                  _askForSmsCode,
                );
                if (!mounted) return;
                // aviso sucesso
                _showSnack('Autenticação por SMS configurada com sucesso.', backgroundColor: const Color(0xff7AE058));
                setState(() => _isSmsAuthEnabled = true);
              } catch (e) {
                if (!mounted) return;
                // aviso erro
                _showSnack('Falha ao ativar 2FA: $e', backgroundColor: Colors.red);
                setState(() => _isSmsAuthEnabled = false); // devolve o switch ao desligado
              }
              _passwordController.clear(); // Limpa a senha 
            },
          ),
        ],
      ),
    );
  }

// CONSTRUÇÃO DA TELA --
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // cabeçalho
      appBar: AppBar(
        title: const Text('PERFIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, 
      ),
      
      // corpo
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            // Autenticação
            _buildCardContainer(
              Column(
                children: [
                  // Título do cartão
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.black, size: 28),
                      SizedBox(width: 12),
                      Text('AUTENTICAÇÃO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Switch email
                  _buildSwitchRow(
                    label: 'Por email:',
                    value: _isEmailAuthEnabled,
                    activeColor:  Color.fromARGB(255, 90, 101, 255),
                    inactiveColor: const Color.fromARGB(255, 255, 30, 0),
                    onChanged: (bool newValue) {
                      setState(() => _isEmailAuthEnabled = newValue);
                    },
                  ),
                  
                  // Switch 2fa
                  _buildSwitchRow(
                    label: 'Por SMS:', 
                    value: _isSmsAuthEnabled,
                    activeColor:  Color.fromARGB(255, 90, 101, 255),
                    inactiveColor: const Color.fromARGB(255, 255, 30, 0),
                    onChanged: (bool newValue) {
                      if (newValue) {
                        _iniciarFluxo2FA(); // inicia o fluxo de segurança 
                      } else {
                        setState(() => _isSmsAuthEnabled = false);
                        _showSnack('2FA Desativado');
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // carteira
            _buildCardContainer(
              Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.black, size: 28),
                      SizedBox(width: 12),
                      Text('CARTEIRA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Saldo disponível:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ),
                  const SizedBox(height: 8),
                  
                  // PARA QUEM FOR INTEGRAR O DADO ESTÁ MOCKADO 
                  // ========================================================
                  const Text('R\$676767,00', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  // =================================================================
                  // botão da pagina da carteira
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WalletPage()));
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5759E0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('Acessar Carteira', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                // Botão Modo Escuro
                Expanded(child: _buildActionButton(label: 'MODO ESCURO', onPressed: () => _showSnack('Modo escuro em breve!'))),
                const SizedBox(width: 16),
                
                // Botão logout 
                Expanded(
                  child: _buildActionButton(
                    label: 'LOG-OUT', 
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut(); // Desloga do firebase
                    }
                  )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Evita repetição
  // ==========================================

  // Cria a caixa branca com borda cinz arredondada
  Widget _buildCardContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCACACA), width: 1),
      ),
      child: child,
    );
  }

  //Linha de liga e desliga o switch
  Widget _buildSwitchRow({required String label, required bool value, required Color activeColor, Color? inactiveColor, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: activeColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: inactiveColor ?? Colors.grey.shade400,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Cria os botões grandes e quadrados do modo escuro e logout
  Widget _buildActionButton({required String label, required VoidCallback onPressed}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCACACA), width: 1),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
    );
  }
}