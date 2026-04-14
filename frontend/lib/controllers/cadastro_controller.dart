import 'package:flutter/material.dart';

class SigninController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final cpfController = TextEditingController();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _validateEmptyFields() {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        cpfController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _errorMessage = 'Todos os campos sao obrigatorios';
      return false;
    }
    return true;
  }

  bool _validateEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(emailController.text)) {
      _errorMessage = 'Email inválido';
      return false;
    }

    return true;
  }

  bool _validateCPF() {
    final cpfRegex = RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$');
    if (!cpfRegex.hasMatch(cpfController.text)) {
      _errorMessage = 'CPF deve ser no formato: xxx.xxx.xxx-xx';
      return false;
    }
    return true;
  }

  bool _validatePassword() {
    if (passwordController.text.length < 8) {
      _errorMessage = 'Senha deve ter no mínimo 8 caracteres';
      return false;
    }
    return true;
  }

  bool validate() {
    _errorMessage = null;
    if (!_validateEmptyFields()) return false;
    if (!_validateEmail()) return false;
    if (!_validateCPF()) return false;
    if (!_validatePassword()) return false;

    return true;
  }

  Future<bool> cadastrar() async {
    if (!validate()) {
      return false;
    }
    // TODO: implementar chamada real ao backend.
    return true;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    cpfController.dispose();
  }
}
