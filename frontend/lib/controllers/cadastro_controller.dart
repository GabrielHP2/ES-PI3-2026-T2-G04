// João Pedro Panza Mainieri - RA: 25006642
import 'package:flutter/material.dart';

class SigninController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final cpfController = TextEditingController();

  final birthDateController = TextEditingController();
  DateTime? birthDate;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _validateEmptyFields() {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        cpfController.text.isEmpty ||
        passwordController.text.isEmpty ||
        birthDateController.text.isEmpty) {
      _errorMessage = 'Todos os campos sao obrigatorios';
      return false;
    }
    return true;
  }

  bool _validateEmail() {
    final emailRegex = RegExp(r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$');
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

  bool _validatePhone() {
    final phoneRegex = RegExp(r'^\+55[1-9]\d{9,10}$');
    if (phoneRegex.hasMatch(phoneController.text)) {
      _errorMessage = 'Telefone deve ter o formato: Ex: +5511987654321';
      return false;
    }
    return true;
  }

  bool _validatePassword() {
    final passwordRegex = RegExp(
      r'^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\d\s:])([^\s]){8,16}$',
    );
    if (passwordRegex.hasMatch(passwordController.text)) {
      _errorMessage =
          'Senha Inválida, a senha deve ter pelo menos: - 8 Caracteres; - 1 Letra maiúscula; - 1 Letra minúscula; - 1 Número;';
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
    if (!_validatePhone()) return false;

    return true;
  }

  void setBirthDate(DateTime date) {
    birthDate = date;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    birthDateController.text = '$day/$month/$year';
  }

  Future<bool> cadastrar() async {
    if (!validate()) {
      return false;
    }
    try {} catch (e) {}
    return true;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    cpfController.dispose();
    birthDateController.dispose();
  }
}
