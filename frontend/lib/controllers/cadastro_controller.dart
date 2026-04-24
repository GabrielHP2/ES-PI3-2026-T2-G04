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

  bool _validatePhone() {
    if (phoneController.text.length != 11) {
      _errorMessage = 'Telefone deve ter 11 dígitos';
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
    // TODO: implementar chamada real ao backend.
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